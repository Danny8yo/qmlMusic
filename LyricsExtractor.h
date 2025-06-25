#ifndef LYRICSEXTRACTOR_H
#define LYRICSEXTRACTOR_H

#include <QObject>
#include <QStringList>
#include <QString>

class LyricsExtractor : public QObject
{
    Q_OBJECT

public:
    explicit LyricsExtractor(QObject *parent = nullptr);

    // 从音频文件中提取歌词
    Q_INVOKABLE QStringList extractLyricsFromFile(const QString &filePath);

    // 从外部 .lrc 文件中加载歌词
    Q_INVOKABLE QStringList loadLyricsFromLrcFile(const QString &lrcFilePath);

    // 根据音频文件路径自动查找对应的 .lrc 文件
    Q_INVOKABLE QStringList findAndLoadLrcFile(const QString &audioFilePath);

    // 解析 LRC 格式歌词，提取时间戳
    Q_INVOKABLE QVariantList parseLrcLyrics(const QStringList &lrcLines);

private:
    // 内部函数：从 ID3v2 标签提取歌词
    QStringList extractFromId3v2(const QString &filePath);

    // 内部函数：清理歌词文本
    QStringList cleanLyricsText(const QString &rawText);
};

#endif // LYRICSEXTRACTOR_H
