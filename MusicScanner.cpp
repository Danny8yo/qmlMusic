#include "MusicScanner.h"
#include <QDirIterator>
#include <QFileInfo>
#include <QMimeDatabase>
#include <QMimeType>
#include <QDebug>

MusicScanner::MusicScanner(QObject* parent) : QObject(parent), m_workerThread(nullptr), m_shouldStop(false)
{
    m_supportedFormats << "*.mp3" << "*.flac" << "*.wav" << "*.aac" << "*.ogg" << "*.m4a";
}

MusicScanner::~MusicScanner()
{
    stopScan();
}

void MusicScanner::startScan(const QStringList& directories)
{
    if (m_workerThread && m_workerThread->isRunning()) { stopScan(); }

    m_scanDirectories = directories;
    m_shouldStop = false;
    m_foundSongs.clear();

    // 创建工作线程
    m_workerThread = new QThread(this);
    moveToThread(m_workerThread);

    connect(m_workerThread, &QThread::started, this, &MusicScanner::doScan);
    connect(m_workerThread, &QThread::finished, m_workerThread, &QThread::deleteLater);

    m_workerThread->start();
}

void MusicScanner::stopScan()
{
    m_shouldStop = true;

    if (m_workerThread) {
        m_workerThread->quit();
        m_workerThread->wait(3000); // 等待3秒
        if (m_workerThread->isRunning()) {
            m_workerThread->terminate();
            m_workerThread->wait(1000);
        }
        m_workerThread = nullptr;
    }
}

void MusicScanner::doScan()
{
    try {
        // 首先计算总文件数
        int totalFiles = countMusicFiles(m_scanDirectories);
        if (totalFiles == 0) {
            emit scanFinished(m_foundSongs);
            return;
        }

        int processedFiles = 0;
        emit scanProgress(0);

        // 扫描每个目录
        for (const QString& directory : m_scanDirectories) {
            if (m_shouldStop) break;

            scanDirectory(directory, processedFiles, totalFiles);
        }

        if (!m_shouldStop) {
            emit scanProgress(100);
            emit scanFinished(m_foundSongs);
        }

    } catch (const std::exception& e) {
        emit scanError(QString("Scan error: %1").arg(e.what()));
    }
}

void MusicScanner::scanDirectory(const QString& dirPath, int& processedFiles, int totalFiles)
{
    QDir dir(dirPath);
    if (!dir.exists()) { return; }

    // 递归迭代目录
    QDirIterator iterator(dirPath, m_supportedFormats, QDir::Files, QDirIterator::Subdirectories);

    while (iterator.hasNext() && !m_shouldStop) {
        QString filePath = iterator.next();

        Song* song = processMusicFile(filePath); // 检查该目录下符合条件的文件

        if (song) { // 加入到QList
            m_foundSongs.append(song);
        }

        processedFiles++;
        if (totalFiles > 0) {
            int progress = (processedFiles * 100) / totalFiles;
            emit scanProgress(progress);
        }
    }
}

int MusicScanner::countMusicFiles(const QStringList& directories)
{
    int count = 0;

    for (const QString& directory : directories) {
        QDirIterator iterator(directory, m_supportedFormats, QDir::Files, QDirIterator::Subdirectories);
        while (iterator.hasNext() && !m_shouldStop) {
            iterator.next();
            count++;
        }
    }

    return count;
}

Song* MusicScanner::processMusicFile(const QString& filePath)
{
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists() || !fileInfo.isReadable()) { return nullptr; }

    // 验证文件是否为音频文件
    QMimeDatabase mimeDb;
    QMimeType mimeType = mimeDb.mimeTypeForFile(filePath);
    if (!mimeType.name().startsWith("audio/")) { return nullptr; }

    qDebug() << fileInfo.baseName();
    qDebug() << "unknown";
    // 创建Song对象
    Song* song = new Song(filePath);

    // 测试设置基本信息（歌曲信息由Song类调用TagLib实现）
    // song->setTitle(fileInfo.baseName());
    // song->setArtist("Unknown");
    // song->setAlbum("Unknown");
    // song->setDuration(0); // 实际实现中应该读取音频文件长度

    // // // 尝试加载元数据
    // song->loadMetadataFromFile();

    return song;
}
