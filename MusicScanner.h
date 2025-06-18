#pragma once

#include <QObject>
#include <QThread>
#include <QStringList>
#include <QDir>
#include <atomic>
#include "song.h"

class MusicScanner : public QObject
{
    Q_OBJECT

public:
    explicit MusicScanner(QObject* parent = nullptr);
    ~MusicScanner();

public slots:
    void startScan(const QStringList& directories);
    //对给定的目录列表开始扫描过程。

    void stopScan();

private slots:
    void doScan(); // 在工作线程中执行

signals:
    void scanProgress(int percentage);
    //发出当前扫描的进度。

    void scanFinished(const QList<Song*>& foundSongs);
    //扫描完成时发出，提供找到的新歌曲列表。
    void scanError(const QString& error);

private:
    QList<Song*> m_foundSongs; //当前路径列表下扫描到的所有歌曲

    QThread* m_workerThread;

    QStringList m_scanDirectories;

    QStringList m_supportedFormats; // {"*.mp3", "*.flac", "*.wav", "*.aac", "*.ogg"}

    std::atomic<bool> m_shouldStop;



    Song* processMusicFile(const QString& filePath); // TagLib处理内嵌元数据

    void scanDirectory(const QString& dirPath, int& processedFiles, int totalFiles); // 递归迭代目录

    int countMusicFiles(const QStringList& directories); // 计算要扫描的文件数
};
