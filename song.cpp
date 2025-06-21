#include "song.h"
#include <QStandardPaths>
#include <QDir>
#include <QDebug>
#include <QFileInfo>
// 引入 TagLib 头文件
#include <taglib/tag.h>
#include <taglib/fileref.h>
#include <taglib/tpropertymap.h>
#include <taglib/mpegfile.h>
#include <taglib/id3v2tag.h>
#include <taglib/attachedpictureframe.h>
#include <taglib/tfilestream.h>
#include <taglib/unsynchronizedlyricsframe.h>
#include <taglib/tstring.h>

Song::Song(QObject *parent) : QObject(parent) {}

Song::Song(const QString &filePath, QObject *parent) : QObject(parent), m_filePath(filePath)
{
    // 构造时自动加载元数据
    loadMetadataFromFile();
}

// Song::Song(const QString &filePath,const QString &title,const QString &artist
//            ,const QString &album,int duration,QObject *parent)
//     : QObject(parent)
//     , m_title(title)
//     , m_artist(artist)
//     , m_album(album)
//     , m_duration(duration)
//     , m_filePath(filePath)
//     {}

Song::Song(const QString &filePath, const QString &title, const int id,const QString &artist, const QString &album, int duration, QObject *parent)
: QObject(parent),
    m_title(title),
    m_id(id),
    m_artist(artist),
    m_album(album),
    m_duration(duration),
    m_filePath(filePath)
    {}

bool Song::loadMetadataFromFile()
{
    if (m_filePath.isEmpty() || !QFile::exists(m_filePath)) {
        qWarning() << "File path is empty or file does not exist:" << m_filePath;
        return false;
    }

    // --- 修正点 ---
    // 将 QString 转换为 TagLib 可接受的 const char*
    TagLib::FileRef f(m_filePath.toLocal8Bit().constData());

    if (f.isNull() || !f.tag()) {
        qWarning() << "Failed to read metadata from:" << m_filePath;
        // 如果无法读取元数据，至少使用文件名作为标题
        setTitle(QFileInfo(m_filePath).baseName());
        return false;
    }

    TagLib::Tag *tag = f.tag();
    /*获取音频属性对象指针
     歌 曲时长不属于“标签”（Tag，如艺术家、专辑名），而是                                   *
     属于文件的**“音频属性”（Audio Properties）**。TagLib 提供了专门的接口来访问这些属性。
     */
    TagLib::AudioProperties *audioProperties = f.audioProperties();

    // toCString(true) 表示使用 UTF-8 编码，这是推荐的做法
    setTitle(QString::fromUtf8(tag->title().toCString(true)));
    // qDebug() << "Title:" << tag->title().toCString(true);
    setArtist(QString::fromUtf8(tag->artist().toCString(true)));
    setAlbum(QString::fromUtf8(tag->album().toCString(true)));
    setDuration(audioProperties ? audioProperties->lengthInSeconds() : 0);

    // 封面部分
    QFileInfo audioFileInfo(m_filePath);

    //  构造封面目录路径
    QString coverDirPath = audioFileInfo.absolutePath() + "/covers";
    QDir coverDir(coverDirPath);

    //  获取不带扩展名的文件名
    QString baseName = audioFileInfo.completeBaseName(); // 保留所有点号前的部分

    // 构造封面文件路径
    QString coverPath = coverDirPath + "/" + baseName + ".jpg";

    setCoverArtPath(QUrl::fromLocalFile(coverPath));
    qDebug() << m_coverArtPath;

    if (title().isEmpty() || title() == "Unknown Title") {
        // qDebug() << "歌曲名称为: "<< this->title();
        // qDebug() << "作者: "<< tag->artist().toCString(true);
        setTitle(QFileInfo(m_filePath).baseName());
    }

    if (f.audioProperties()) { setDuration(f.audioProperties()->lengthInSeconds()); }

    // 现在可以调用提取函数了
    // extractEmbeddedCover();
    // extractEmbeddedLyrics();

    return true;
}

// bool Song::extractEmbeddedCover()
// {
//     TagLib::MPEG::File file(m_filePath.toStdWString().c_str());
//     if (!file.isValid() || !file.ID3v2Tag()) {
//         return false;
//     }

//     TagLib::ID3v2::Tag *id3v2tag = file.ID3v2Tag();
//     const auto frameList = id3v2tag->frameListMap()["APIC"];

//     if (frameList.isEmpty()) {
//         return false;
//     }

//     auto pictureFrame = static_cast<TagLib::ID3v2::AttachedPictureFrame *>(frameList.front());
//     if (!pictureFrame) {
//         return false;
//     }

//     // 创建缓存路径
//     QString cacheDir = ensureCachePath("covers");
//     QString fileSuffix;
//     QString mimeType = pictureFrame->mimeType().toCString();
//     if (mimeType == "image/jpeg") fileSuffix = ".jpg";
//     else if (mimeType == "image/png") fileSuffix = ".png";
//     else fileSuffix = ".jpg"; // 默认

//     // 使用歌曲信息的哈希值或唯一标识来创建文件名，避免冲突
//     QString coverFileName = QString::number(qHash(m_artist + m_album + m_title)) + fileSuffix;
//     QString coverPath = cacheDir + "/" + coverFileName;

//     // 如果文件已存在，则直接使用
//     if(QFile::exists(coverPath)) {
//         setCoverArtPath(QUrl::fromLocalFile(coverPath));
//         return true;
//     }

//     // 将封面数据写入文件
//     QFile coverFile(coverPath);
//     if (coverFile.open(QIODevice::WriteOnly)) {
//         coverFile.write(pictureFrame->picture().data(), pictureFrame->picture().size());
//         coverFile.close();
//         setCoverArtPath(QUrl::fromLocalFile(coverPath));
//         qDebug() << "Extracted cover to:" << coverPath;
//         return true;
//     }

//     return false;
// }

// bool Song::extractEmbeddedLyrics()
// {
//     TagLib::MPEG::File file(m_filePath.toStdWString().c_str());
//     if (!file.isValid() || !file.ID3v2Tag()) {
//         return false;
//     }

//     const auto frameList = file.ID3v2Tag()->frameListMap()["USLT"];
//     if (frameList.isEmpty()) {
//         return false;
//     }

//     auto lyricsFrame = static_cast<TagLib::ID3v2::UnsynchronizedLyricsFrame *>(frameList.front());
//     if (!lyricsFrame) {
//         return false;
//     }

//     // 创建缓存路径
//     QString cacheDir = ensureCachePath("lyrics");
//     QString lyricsFileName = QString::number(qHash(m_artist + m_album + m_title)) + ".txt";
//     QString lyricsFilePath = cacheDir + "/" + lyricsFileName;

//     // 将歌词写入文件
//     QFile lyricsFile(lyricsFilePath);
//     if (lyricsFile.open(QIODevice::WriteOnly | QIODevice::Text)) {
//         QTextStream out(&lyricsFile);
//         out.setCodec("UTF-8");
//         out << QString::fromStdString(lyricsFrame->text().to8Bit(true));
//         lyricsFile.close();
//         setLyricsPath(lyricsFilePath);
//         qDebug() << "Extracted lyrics to:" << lyricsFilePath;
//         return true;
//     }

//     return false;
// }

// --- Getters ---
int Song::id() const
{
    return m_id;
}
QString Song::title() const
{
    return m_title;
}
QString Song::artist() const
{
    return m_artist;
}
QString Song::album() const
{
    return m_album;
}
int Song::duration() const
{
    return m_duration;
}
QString Song::filePath() const
{
    return m_filePath;
}
QUrl Song::coverArtPath() const
{
    return m_coverArtPath;
}
QString Song::lyricsPath() const
{
    return m_lyricsPath;
}

QString Song::durationString() const
{
    if (m_duration <= 0) { return "00:00"; }
    int seconds = m_duration % 60;
    int minutes = m_duration / 60;
    return QString("%1:%2").arg(minutes, 2, 10, QChar('0')).arg(seconds, 2, 10, QChar('0'));
}

// --- Setters ---
void Song::setId(int id)
{
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Song::setTitle(const QString &title)
{
    QString finalTitle = title.isEmpty() ? "Unknown Title" : title;
    if (m_title != finalTitle) {
        m_title = finalTitle;
        // qDebug() << "已将标题设置为: "<< this->title();
        emit titleChanged();
    }
}

void Song::setArtist(const QString &artist)
{
    QString finalArtist = artist.isEmpty() ? "Unknown Artist" : artist;
    if (m_artist != finalArtist) {
        m_artist = finalArtist;
        emit artistChanged();
    }
}

void Song::setAlbum(const QString &album)
{
    QString finalAlbum = album.isEmpty() ? "Unknown Album" : album;
    if (m_album != finalAlbum) {
        m_album = finalAlbum;
        emit albumChanged();
    }
}

void Song::setDuration(int duration)
{
    if (m_duration != duration) {
        m_duration = duration;
        emit durationChanged();
    }
}

void Song::setFilePath(const QString &filePath)
{
    if (m_filePath != filePath) {
        m_filePath = filePath;
        emit filePathChanged();
    }
}

void Song::setCoverArtPath(const QUrl &coverArtPath)
{
    if (m_coverArtPath != coverArtPath) {
        m_coverArtPath = coverArtPath;
        emit coverArtPathChanged();
    }
}

void Song::setLyricsPath(const QString &lyricsPath)
{
    //qDebug() << "have cover";
    if (m_lyricsPath != lyricsPath) {
        m_lyricsPath = lyricsPath;

        emit lyricsPathChanged();
    }
}

// --- Private Helper ---
QString Song::ensureCachePath(const QString &subfolder)
{
    QString cacheRoot = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    if (cacheRoot.isEmpty()) { cacheRoot = QDir::tempPath(); }
    QString specificCachePath = cacheRoot + "/" + subfolder;
    QDir dir(specificCachePath);
    if (!dir.exists()) { dir.mkpath("."); }
    return specificCachePath;
}
