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
    TagLib::FileRef f(m_filePath.toLocal8Bit().constData());
    TagLib::Tag *tag = f.tag();
    /*获取音频属性对象指针
     歌 曲时长不属于“标签”（Tag，如艺术家、专辑名），而是                                   *
     属于文件的**“音频属性”（Audio Properties）**。TagLib 提供了专门的接口来访问这些属性。
     */
    setDuration(f.audioProperties() ? f.audioProperties()->lengthInSeconds() : 0);
    // qDebug() << "构造时设置歌曲时间: " << m_duration;

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

    // 封面部分
    QFileInfo audioFileInfo(m_filePath);

    //  构造封面目录路径
    QString coverDirPath = audioFileInfo.absolutePath() + "/covers";
    QDir coverDir(coverDirPath);

    //  获取不带扩展名的文件名
    QString baseName = audioFileInfo.completeBaseName(); // 保留所有点号前的部分

    // 构造封面文件路径
    QString coverPath = coverDirPath + "/" + baseName + ".jpg";

    setCoverArtUrl(QUrl::fromLocalFile(coverPath));

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
QUrl Song::coverArtUrl() const
{
    return m_coverArtUrl;
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

bool Song::isFavorite() const
{
    return m_favorite;
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

void Song::setCoverArtUrl(const QUrl &coverArtUrl)
{
    if (m_coverArtUrl != coverArtUrl) {
        m_coverArtUrl = coverArtUrl;
        emit coverArtUrlChanged();
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

void Song::setIsFavorite(bool favorite)
{
    if (m_favorite != favorite) {
        m_favorite = favorite;
        emit favoriteChanged(m_favorite);

        // 调试输出
        qDebug() << "Song" << m_title << "favorite status changed to:" << m_favorite;
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
