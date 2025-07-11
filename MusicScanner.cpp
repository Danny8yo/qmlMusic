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

    m_scanDirectories = directories; // 存放的多个目录
    m_shouldStop = false;
    
    // 清理之前的Song对象并清空列表
    for (Song* song : m_foundSongs) {
        if (song) {
            song->deleteLater();
        }
    }
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

        //
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

//参数1 扫描路径. 2& processedFiles 已处理的文件数, 3 totalFiles 总文件数
void MusicScanner::scanDirectory(const QString& dirPath, int& processedFiles, int totalFiles)
{
    QDir dir(dirPath);
    if (!dir.exists()) {qDebug() << "路径不存在"; return; }
    // qDebug() << "扫描目录: " << dirPath;

    // 递归迭代目录
    QDirIterator iterator(dirPath, m_supportedFormats, QDir::Files, QDirIterator::Subdirectories);

    while (iterator.hasNext() && !m_shouldStop) {
        QString filePath = iterator.next();

        Song* song = processMusicFile(filePath); // 检查该目录下符合条件的文件

        if (song) { // 加入到QList
            m_foundSongs.append(song);
            // qDebug() << "添加歌曲: " << m_foundSongs.back()->title();
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

        //directory		要扫描的根目录路径（如 "/Music"）
        //m_supportedFormats文件格式过滤器（如 ["*.mp3", "*.flac"]）
        //QDir::Files 控制迭代器返回的内容类型 只遍历文件，忽略子目录//QDir::File只返回文件//QDir::Dirs	只返回目录
        //QDirIterator::Subdirectories 启用递归扫描子目录
        while (iterator.hasNext() && !m_shouldStop) {
            iterator.next();
            count++;
        }
    }
    // qDebug() << "扫描到: " << count << "首歌曲";

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

    // qDebug() << fileInfo.baseName();
    // qDebug() << "unknown";
    // 创建Song对象，设置parent为this以确保内存管理
    Song* song = new Song(filePath, this);

    // 测试设置基本信息（歌曲信息由Song类调用TagLib实现）
    // song->setTitle(fileInfo.baseName());
    // song->setArtist("Unknown");
    // song->setAlbum("Unknown");
    // song->setDuration(0); // 实际实现中应该读取音频文件长度

    // // // 尝试加载元数据
    // song->loadMetadataFromFile();

    return song;
}
