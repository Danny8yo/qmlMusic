#include "LyricsExtractor.h"
#include <QFile>
#include <QTextStream>
#include <QFileInfo>
#include <QDir>
#include <QDebug>
#include <QRegularExpression>
#include <QVariantMap>
#include <QStringConverter>

#include <taglib/tag.h>
#include <taglib/fileref.h>
#include <taglib/tpropertymap.h>
#include <taglib/id3v2tag.h>
#include <taglib/unsynchronizedlyricsframe.h>
#include <taglib/textidentificationframe.h>
#include <taglib/mpegfile.h>

LyricsExtractor::LyricsExtractor(QObject *parent)
    : QObject{parent}
{
}

QStringList LyricsExtractor::extractLyricsFromFile(const QString &filePath)
{
    QStringList lyricsList;

    // 首先尝试从音频文件内部提取歌词
    lyricsList = extractFromId3v2(filePath);

    // 如果内部没有歌词，尝试查找外部 .lrc 文件
    if (lyricsList.isEmpty())
    {
        lyricsList = findAndLoadLrcFile(filePath);
    }

    return lyricsList;
}

QStringList LyricsExtractor::loadLyricsFromLrcFile(const QString &lrcFilePath)
{
    QStringList lyricsList;
    QFile file(lrcFilePath);

    if (file.open(QIODevice::ReadOnly | QIODevice::Text))
    {
        QTextStream in(&file);
        in.setEncoding(QStringConverter::Utf8); // 确保正确读取中文

        while (!in.atEnd())
        {
            QString line = in.readLine().trimmed();
            if (!line.isEmpty())
            {
                lyricsList.append(line);
            }
        }

        qDebug() << "从 .lrc 文件加载了" << lyricsList.size() << "行歌词";
    }
    else
    {
        qWarning() << "无法打开 .lrc 文件:" << lrcFilePath;
    }

    return lyricsList;
}

QStringList LyricsExtractor::findAndLoadLrcFile(const QString &audioFilePath)
{
    QFileInfo audioInfo(audioFilePath);
    QString baseName = audioInfo.completeBaseName(); // 不包含扩展名的文件名
    QString dirPath = audioInfo.absolutePath();

    // 可能的 .lrc 文件路径
    QStringList possibleLrcPaths = {
        dirPath + "/" + baseName + ".lrc",
        dirPath + "/" + audioInfo.baseName() + ".lrc"};

    for (const QString &lrcPath : possibleLrcPaths)
    {
        if (QFile::exists(lrcPath))
        {
            qDebug() << "找到对应的 .lrc 文件:" << lrcPath;
            return loadLyricsFromLrcFile(lrcPath);
        }
    }

    qDebug() << "未找到对应的 .lrc 文件，尝试的路径:" << possibleLrcPaths;
    return QStringList();
}

// 用于拆分歌词为时间戳和歌词文本,给qml的ListView作为model
QVariantList LyricsExtractor::parseLrcLyrics(const QStringList &lrcLines)
{
    QVariantList parsedLyrics;
    // 支持多种时间戳格式：[mm:ss.sss], [mm:ss.ss], [mm:ss.s], [mm:ss]
    QRegularExpression timeRegex(R"(\[(\d{1,2}):(\d{1,2})(?:\.(\d{1,3}))?\])");

    for (const QString &line : lrcLines)
    {
        QRegularExpressionMatch match = timeRegex.match(line);
        if (match.hasMatch())
        {
            qDebug() << "匹配到时间戳格式,当前行:" << line;
            // 提取时间戳
            int minutes = match.captured(1).toInt();
            int seconds = match.captured(2).toInt();
            QString millisecondsStr = match.captured(3); // 毫秒部分可能为空

            // 处理毫秒部分
            int milliseconds = 0;
            if (!millisecondsStr.isEmpty())
            {
                // 根据毫秒位数进行标准化处理
                if (millisecondsStr.length() == 1)
                {
                    milliseconds = millisecondsStr.toInt() * 100; // .5 -> 500ms
                }
                else if (millisecondsStr.length() == 2)
                {
                    milliseconds = millisecondsStr.toInt() * 10; // .50 -> 500ms
                }
                else
                {
                    milliseconds = millisecondsStr.toInt(); // .500 -> 500ms
                }
            }

            // 转换为总毫秒数
            qint64 totalMs = minutes * 60 * 1000 + seconds * 1000 + milliseconds;

            // 提取歌词文本（去掉时间戳部分）
            QString lyricsText = line.mid(match.capturedEnd()).trimmed();

            // 跳过空歌词行和各种标识信息
            if (!lyricsText.isEmpty() &&
                !lyricsText.startsWith("作词") &&
                !lyricsText.startsWith("作曲") &&
                !lyricsText.startsWith("编曲") &&
                !lyricsText.startsWith("制作人") &&
                !lyricsText.startsWith("Written by") &&
                !lyricsText.contains("QQ音乐动态歌词"))
            {
                QVariantMap lyricsItem;
                lyricsItem["time"] = totalMs;
                lyricsItem["text"] = lyricsText;
                parsedLyrics.append(lyricsItem);
            }
        }
    }

    qDebug() << "解析得到" << parsedLyrics.size() << "行有效歌词";
    return parsedLyrics;
}

QStringList LyricsExtractor::extractFromId3v2(const QString &filePath)
{
    QStringList lyricsList;

    // 使用 TagLib 打开文件
    TagLib::FileRef f(filePath.toStdString().c_str());

    if (!f.isNull())
    {
        // 对于 MP3 文件，直接访问 MPEG 文件对象
        TagLib::MPEG::File *mpegFile = dynamic_cast<TagLib::MPEG::File *>(f.file());
        if (mpegFile && mpegFile->ID3v2Tag())
        {
            TagLib::ID3v2::Tag *id3v2tag = mpegFile->ID3v2Tag();

            // 查找 TXXX 帧（用户定义文本信息帧）
            auto txxxIt = id3v2tag->frameListMap().find("TXXX");
            if (txxxIt != id3v2tag->frameListMap().end())
            {
                for (auto frame : txxxIt->second)
                {
                    QString frameText = QString::fromStdString(frame->toString().to8Bit(true));
                    // 检查是否包含歌词
                    if (frameText.contains("lyrics") || (frameText.contains("[") &&
                                                         frameText.contains("]") && frameText.contains(":")))
                    {
                        lyricsList = cleanLyricsText(frameText);
                        if (!lyricsList.isEmpty())
                        {
                            qDebug() << "从 TXXX 帧成功提取歌词";
                            return lyricsList;
                        }
                    }
                }
            }

            // 查找标准的 USLT 帧
            auto usltIt = id3v2tag->frameListMap().find("USLT");
            if (usltIt != id3v2tag->frameListMap().end())
            {
                TagLib::ID3v2::UnsynchronizedLyricsFrame *lyricsFrame =
                    dynamic_cast<TagLib::ID3v2::UnsynchronizedLyricsFrame *>(usltIt->second.front());
                if (lyricsFrame)
                {
                    QString lyricsText = QString::fromStdWString(lyricsFrame->text().toWString());
                    lyricsList = cleanLyricsText(lyricsText);
                    if (!lyricsList.isEmpty())
                    {
                        qDebug() << "从 USLT 帧成功提取歌词";
                        return lyricsList;
                    }
                }
            }

            // 查找其他可能包含歌词的文本帧
            for (auto frameIt = id3v2tag->frameListMap().begin();
                 frameIt != id3v2tag->frameListMap().end(); ++frameIt)
            {
                QString frameId = QString::fromStdString(frameIt->first.data());
                if (frameId.startsWith("T"))
                { // 文本帧
                    for (auto frame : frameIt->second)
                    {
                        QString frameText = QString::fromStdString(frame->toString().to8Bit(true));
                        // 检查是否包含时间戳格式的歌词
                        if (frameText.length() > 100 && frameText.contains("[") &&
                            frameText.contains("]") && frameText.contains(":"))
                        {
                            lyricsList = cleanLyricsText(frameText);
                            if (!lyricsList.isEmpty())
                            {
                                qDebug() << "从" << frameId << "帧成功提取歌词";
                                return lyricsList;
                            }
                        }
                    }
                }
            }
        }

        // 尝试使用通用的属性映射
        TagLib::PropertyMap properties = f.file()->properties();
        for (auto it = properties.begin(); it != properties.end(); ++it)
        {
            QString key = QString::fromStdString(it->first.to8Bit(true));
            QString value = QString::fromStdString(it->second.toString().to8Bit(true));

            // 查找歌词相关的键
            if (key.toLower().contains("lyric") || key.toLower() == "lyrics-eng" ||
                key.toLower() == "lyrics")
            {
                lyricsList = cleanLyricsText(value);
                if (!lyricsList.isEmpty())
                {
                    qDebug() << "从属性" << key << "成功提取歌词";
                    return lyricsList;
                }
            }
        }
    }

    return lyricsList;
}

QStringList LyricsExtractor::cleanLyricsText(const QString &rawText)
{
    QStringList lines = rawText.split('\n', Qt::SkipEmptyParts);
    QStringList cleanedLines;

    for (QString line : lines)
    {
        line = line.trimmed();

        // 跳过包含标识符的第一行（如 [lyrics-eng]）
        if (line.startsWith("[lyrics-") && line.endsWith("]") && line.length() < 20)
        {
            continue;
        }

        // 跳过空行
        if (line.isEmpty())
        {
            continue;
        }

        cleanedLines.append(line);
    }

    return cleanedLines;
}
