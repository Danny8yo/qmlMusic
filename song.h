#pragma once
#include <QObject>
#include <QString>
#include <QUrl>
#include <QtQml/qqmlregistration.h>
class Song : public QObject {
    Q_OBJECT
    // 定义QML可访问的属性
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString title READ title WRITE setTitle NOTIFY titleChanged)
    Q_PROPERTY(QString artist READ artist WRITE setArtist NOTIFY artistChanged)
    Q_PROPERTY(QString album READ album WRITE setAlbum NOTIFY albumChanged)
    Q_PROPERTY(int duration READ duration WRITE setDuration NOTIFY durationChanged)
    Q_PROPERTY(QString filePath READ filePath WRITE setFilePath NOTIFY filePathChanged)
    Q_PROPERTY(QUrl coverArtUrl READ coverArtUrl WRITE setCoverArtUrl NOTIFY coverArtUrlChanged)
    Q_PROPERTY(QString lyricsPath READ lyricsPath WRITE setLyricsPath NOTIFY lyricsPathChanged)
    Q_PROPERTY(QString durationString READ durationString NOTIFY durationChanged) // 提供格式化的时长字符串
    QML_ELEMENT

public:
    // 构造函数
    explicit Song(const QString& filePath, QObject* parent = nullptr);
    Song(const QString& filePath, const QString& title,const int id=-1, const QString& artist="unknown",
         const QString& album="unknown", int duration=0, QObject* parent = nullptr);
    Song(QObject* parent = nullptr); // 默认构造函数

    // 使用TagLib从音频文件加载元数据
    Q_INVOKABLE bool loadMetadataFromFile();
    // 从文件提取内嵌封面并保存到缓存目录
    // Q_INVOKABLE bool extractEmbeddedCover();
    // 从文件提取内嵌歌词并保存到缓存目录
    // Q_INVOKABLE bool extractEmbeddedLyrics();

    // Getter
    int id() const;
    QString title() const;
    QString artist() const;
    QString album() const;
    int duration() const;
    QString filePath() const;
    QUrl coverArtUrl() const;
    QString lyricsPath() const;
    //格式化时长为字符串00:00
    QString durationString() const;

    // Setter
    void setId(int id);
    void setTitle(const QString& title);
    void setArtist(const QString& artist);
    void setAlbum(const QString& album);
    void setDuration(int duration);
    void setFilePath(const QString& filePath);
    void setCoverArtUrl(const QUrl& coverArtUrl);
    void setLyricsPath(const QString& lyricsPath);

signals:
    // 属性变化时发出的信号
    void idChanged();
    void titleChanged();
    void artistChanged();
    void albumChanged();
    void durationChanged();
    void filePathChanged();
    void coverArtUrlChanged();
    void lyricsPathChanged();

private:
    // 内部成员变量
    int m_id = -1;
    QString m_title = "Unknown Title";
    QString m_artist = "Unknown Artist";
    QString m_album = "Unknown Album";
    int m_duration = 0; // 时长（秒）
    QString m_filePath; //音乐路径
    QUrl m_coverArtUrl;
    QString m_lyricsPath;

    // 辅助函数，用于确保缓存目录存在
    QString ensureCachePath(const QString& subfolder);
};
