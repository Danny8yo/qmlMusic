#pragma once
#include <QObject>
#include <QMediaPlayer>
#include <QAudioOutput>
#include <QList>
#include <QTimer>
#include <QtQml/qqmlregistration.h>
#include "song.h"

class PlayerController : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QMediaPlayer::PlaybackState playbackState READ playbackState NOTIFY playbackStateChanged)
    Q_PROPERTY(qint64 position READ position WRITE setPosition NOTIFY positionChanged)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(int volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(Song *currentSong READ currentSong NOTIFY currentSongChanged)
    Q_PROPERTY(PlaybackMode playbackMode READ playbackMode WRITE setPlaybackMode NOTIFY playbackModeChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying NOTIFY playbackStateChanged)
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY queueChanged)
    Q_PROPERTY(QList<Song *> playQueue READ playQueue NOTIFY queueChanged)
    QML_ELEMENT

public:
    enum PlaybackMode
    {
        Sequential, // 顺序播放（列表播放完后不继续播放）
        Loop,       // 循环播放（列表播放完后从头开始播放）
        Random,     // 随机播放
        RepeatOne   // 单曲循环
    };
    Q_ENUM(PlaybackMode)

    explicit PlayerController(QObject *parent = nullptr);

    // Getters
    QMediaPlayer::PlaybackState playbackState() const;
    qint64 position() const;
    qint64 duration() const;
    int volume() const;
    Song *currentSong() const { return m_currentSong; }
    PlaybackMode playbackMode() const { return m_playbackMode; }
    bool isPlaying() const { return playbackState() == QMediaPlayer::PlayingState; }
    int currentIndex() const { return m_currentIndex; }
    QList<Song *> playQueue() const { return m_playQueue; }

public slots:
    // 播放控制
    void play();
    void pause();
    void stop();
    void next();
    void previous();
    void seek(qint64 position); // 定位
    void setPosition(qint64 position);
    void setVolume(int volume);              // 音量
    void setPlaybackMode(PlaybackMode mode); // 播放状态

    // 队列管理
    // void playFile(const QString& filePath);    //播放指定目录文件下的歌曲
    void playSong(Song *song);                  // 播放指定歌曲
    void playQueueIndex(int index);             // 播放指定索引歌曲
    void addToQueue(Song *song);                // 添加歌曲到播放队列
    void removeFromQueue(int index);            // 从队列中移出歌曲
    void clearQueue();                          // 清空
    void loadQueue(const QList<Song *> &songs); // 加载新队列（可以是某个歌单，可以直接从Playlist类获取）

signals:
    void playbackStateChanged();           // 播放状态变化（播放/暂停/停止）
    void positionChanged(qint64 position); // 位置
    void durationChanged();                // 时长
    void currentSongChanged();             // 当前播放歌曲
    void volumeChanged();                  // 音量
    void playbackModeChanged();            // 播放模式变化（单曲/随机/循环）
    void queueChanged();                   // 播放列表变化

private slots:
    void onPositionChanged(qint64 position);
    void onDurationChanged(qint64 duration);
    void onMediaStatusChanged(QMediaPlayer::MediaStatus status);

private:
    QMediaPlayer *m_player;
    QAudioOutput *m_audioOutput;
    QList<Song *> m_playQueue;    // 播放队列
    int m_currentIndex;           // 当前索引
    PlaybackMode m_playbackMode;  // 播放模式
    Song *m_currentSong;          // 正在播放的歌曲
    void updateCurrentSong();     // 更新正在播放的歌曲
    int getNextIndex() const;     // 获取下一首歌的索引
    int getPreviousIndex() const; // 获取上一手歌的索引
};
