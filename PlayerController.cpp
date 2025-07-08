#include "PlayerController.h"
#include <QUrl>
#include <QFileInfo>
#include <QRandomGenerator>
#include <QDebug>

PlayerController::PlayerController(QObject* parent)
    : QObject(parent)
    , m_player(new QMediaPlayer(this))
    , m_audioOutput(new QAudioOutput(this))
    , m_currentIndex(-1)
    , m_playbackMode(Loop)
    , m_currentSong(nullptr)
{
    m_player->setAudioOutput(m_audioOutput);
    m_audioOutput->setVolume(1.0f); // 默认音量70%

    // 连接信号
    connect(m_player, &QMediaPlayer::positionChanged, this, &PlayerController::onPositionChanged);
    connect(m_player, &QMediaPlayer::durationChanged, this, &PlayerController::onDurationChanged);
    connect(m_player, &QMediaPlayer::playbackStateChanged, this, &PlayerController::playbackStateChanged);
    connect(m_player, &QMediaPlayer::mediaStatusChanged, this, &PlayerController::onMediaStatusChanged);
}

QMediaPlayer::PlaybackState PlayerController::playbackState() const
{
    return m_player->playbackState();
}

qint64 PlayerController::position() const
{
    return m_player->position();
}

qint64 PlayerController::duration() const
{
    return m_player->duration();
}

int PlayerController::volume() const
{
    return qRound(m_audioOutput->volume() * 100);
}

void PlayerController::play()
{
    m_player->play();
    qDebug() << "start to play" << m_playQueue.size() << m_currentIndex;
    // if (m_currentIndex >= 0 && m_currentIndex < m_playQueue.size()) {
    //     m_player->play();
    //     qDebug() << "start to play";
    // }
}

void PlayerController::pause()
{
    m_player->pause();
}

void PlayerController::stop()
{
    m_player->stop();
}

void PlayerController::next()
{
    int nextIndex = getNextIndex();
    if (nextIndex >= 0) { playQueueIndex(nextIndex); }
}

void PlayerController::previous()
{
    int prevIndex = getPreviousIndex();
    if (prevIndex >= 0) { playQueueIndex(prevIndex); }
}

void PlayerController::seek(qint64 position)
{
    m_player->setPosition(position);
}

void PlayerController::setPosition(qint64 position)
{
    seek(position);
}

void PlayerController::setVolume(int volume)
{
    float normalizedVolume = qBound(0, volume, 100) / 100.0f;
    m_audioOutput->setVolume(normalizedVolume);
    emit volumeChanged();
}

void PlayerController::setPlaybackMode(PlaybackMode mode)
{
    if (m_playbackMode != mode) {
        m_playbackMode = mode;
        emit playbackModeChanged();
    }
}

void PlayerController::playSong(Song* song)
{
    if (!song) return;

    QFileInfo fileInfo(song->filePath());
    if (!fileInfo.exists()) {
        qDebug() << "Song file does not exist:" << song->filePath();
        return;
    }

    // 查找歌曲在队列中的位置
    int index = m_playQueue.indexOf(song);
    if (index >= 0) {
        playQueueIndex(index);
    } else {
        // 如果不在队列中，添加到队列并播放
        addToQueue(song);
        playQueueIndex(m_playQueue.size() - 1);
    }
}

void PlayerController::playQueueIndex(int index) //播放指定索引歌曲
{
    if (index < 0 || index >= m_playQueue.size()) { return; }

    m_currentIndex = index;
    updateCurrentSong();

    if (m_currentSong) {
        QUrl fileUrl = QUrl::fromLocalFile(m_currentSong->filePath());
        m_player->setSource(fileUrl);
        m_player->play();
    }
}

void PlayerController::addToQueue(Song* song) //增加
{
    if (song && !m_playQueue.contains(song)) {
        m_playQueue.append(song);
        emit queueChanged();
    }
}

void PlayerController::removeFromQueue(int index) //移出
{
    if (index >= 0 && index < m_playQueue.size()) {
        m_playQueue.removeAt(index);

        // 调整当前索引
        if (index < m_currentIndex) {
            m_currentIndex--;
        } else if (index == m_currentIndex) {
            // 如果删除的是当前歌曲，停止播放
            stop();
            m_currentIndex = -1;
            updateCurrentSong();
        }

        emit queueChanged();
    }
}

void PlayerController::clearQueue()
{
    if (!m_playQueue.isEmpty()) {
        stop();
        m_playQueue.clear();
        m_currentIndex = -1;
        updateCurrentSong();
        emit queueChanged();
    }
}

void PlayerController::loadQueue(const QList<Song*>& songs)
{
    // if (!m_playQueue.isEmpty()) { clearQueue(); }

    // m_playQueue = songs;
    // emit queueChanged();
    // 加入新播放队列后要覆盖原队列，因此要clear
    clearQueue(); // 重置 m_currentIndex = -1
    m_playQueue = songs;
    emit queueChanged();

    // 加入新播放队列后的自动播放逻辑
    if (!m_playQueue.isEmpty()) {
        playQueueIndex(0); // 自动设置索引并播放
    }
}

void PlayerController::onPositionChanged(qint64 position)
{
    emit positionChanged(position);
}

void PlayerController::onDurationChanged(qint64 duration)
{
    emit durationChanged();
}

void PlayerController::onMediaStatusChanged(QMediaPlayer::MediaStatus status)
{
    if (status == QMediaPlayer::EndOfMedia) {
        // 歌曲播放结束，自动播放下一首
        if (m_playbackMode == RepeatOne) {
            // 单曲循环
            seek(0);
            play();
        } else {
            next();
        }
    }
}

void PlayerController::updateCurrentSong()
{
    Song* newCurrentSong = nullptr; // 默认无歌曲

    //检查索引，并获取对应歌曲
    if (m_currentIndex >= 0 && m_currentIndex < m_playQueue.size()) { newCurrentSong = m_playQueue.at(m_currentIndex); }

    if (m_currentSong != newCurrentSong) { // 比较新旧歌曲
        m_currentSong = newCurrentSong;
        emit currentSongChanged();
    }
}

int PlayerController::getNextIndex() const
{
    if (m_playQueue.isEmpty()) { return -1; }

    switch (m_playbackMode) {
    // case Sequential: // 顺序
    //     return (m_currentIndex + 1 < m_playQueue.size()) ? m_currentIndex + 1 : -1;

    case Loop: // 循环
        return (m_currentIndex + 1) % m_playQueue.size();

    case Random: { // 随机
        if (m_playQueue.size() <= 1) { return m_currentIndex; }
        int randomIndex;
        do {
            randomIndex = QRandomGenerator::global()->bounded(m_playQueue.size());
        } while (randomIndex == m_currentIndex);
        return randomIndex;
    }

    case RepeatOne: //单曲
        return m_currentIndex;

    default:
        return -1;
    }
}

int PlayerController::getPreviousIndex() const
{
    if (m_playQueue.isEmpty()) { return -1; }

    switch (m_playbackMode) {
    // case Sequential:
    //     return (m_currentIndex > 0) ? m_currentIndex - 1 : -1;

    case Loop:
        return (m_currentIndex > 0) ? m_currentIndex - 1 : m_playQueue.size() - 1;

    case Random: {
        if (m_playQueue.size() <= 1) { return m_currentIndex; }
        int randomIndex;
        do {
            randomIndex = QRandomGenerator::global()->bounded(m_playQueue.size());
        } while (randomIndex == m_currentIndex);
        return randomIndex;
    }

    case RepeatOne:
        return m_currentIndex;

    default:
        return -1;
    }
}
