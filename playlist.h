#pragma once
#include <QObject>
#include <QString>
#include <QDateTime>
#include <QList>
#include "song.h"

class Playlist : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(bool local READ local WRITE setLocal NOTIFY localChanged FINAL)
    Q_PROPERTY(QString name READ name WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged)
    Q_PROPERTY(QDateTime creationDate READ creationDate WRITE setCreationDate NOTIFY creationDateChanged)
    Q_PROPERTY(QUrl coverUrl READ coverUrl NOTIFY coverUrlChanged)
    Q_PROPERTY(int songCount READ songCount NOTIFY songCountChanged)

    //QML_ELEMENT// playlsit类需要在外部创建(歌单可能不存在，但是歌曲一定是都有的)

public:
    explicit Playlist(QObject* parent = nullptr);
    explicit Playlist(const QString& name, QObject* parent = nullptr);
    //创建所有自定义歌曲列表
    explicit Playlist(const int &id,const QString &name, const QString &description,const QDateTime &date,QObject *parent);

    // Getters
    int id() const { return m_id; }
    bool local() const { return m_local; }
    QString name() const { return m_name; }
    QString description() const { return m_description; }
    QDateTime creationDate() const { return m_creationDate; }
    QUrl coverUrl() const { return m_coverUrl; }
    int songCount() const { return m_songs.size(); }

    // Setters
    void setId(int id);
    void setLocal(bool local);
    void setName(const QString& name);
    void setDescription(const QString& description);
    void setCreationDate(const QDateTime& creationDate);
    void setCoverUrl(const QUrl& coverUrl);
    void setSongs(const QList<Song *> &songs);

    // 歌曲管理
    Q_INVOKABLE void addSong(Song* song);//添加一首歌到歌单
    Q_INVOKABLE void removeSong(int index);
    Q_INVOKABLE void clearSongs();
    Q_INVOKABLE Song* getSong(int index) const;//获得指定索引的歌曲
    Q_INVOKABLE QList<Song*> getAllSongs() const;
    Q_INVOKABLE void updateCoverUrl();//设置第一首歌曲为歌单封面

    //输出相对路径到数据库
    QString relativeCoverPath();

signals:
    void idChanged();
    void localChanged();
    void nameChanged();
    void descriptionChanged();
    void creationDateChanged();
    void coverUrlChanged();
    void songCountChanged();
    void songsChanged();

private:
    int m_id;
    bool m_local{false}; // 是否为本地（用户新建歌单的标识，默认为false）
    QString m_name;
    QString m_description;
    QDateTime m_creationDate;
    QUrl m_coverUrl;
    QList<Song*> m_songs;//用于管理歌曲列表,承接musicScanner move的共享指针
};
