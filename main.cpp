#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include "MusicScanner.h"
#include "playlist.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("qmltest", "Main");

    // 扫描/home/lius/Music/no_cover_mp3s/目录下的歌曲
    QString musicDir = "/home/lius/Music/no_cover_mp3s/";
    QStringList pathList;
    pathList.append(musicDir);
    // qDebug()<< pathList[0];
    Playlist *myLike = new Playlist("My Like");
    MusicScanner *scannerDir = new MusicScanner();

    QObject::connect(scannerDir, &MusicScanner::scanFinished, &app,
                     [scannerDir,myLike](const QList<Song*>& foundSongs) {
                        //foundSongs 引用的是 MusicScanner 对象内部，通过 scanFinished 信号发出的那个列表。
                         qDebug() << "\n--- 扫描完成！正在处理结果。 ---";
                         qDebug() << "最终歌曲数量:" << foundSongs.size();

                         for (const auto &song : foundSongs)
                         {
                             myLike->addSong(song);
                         }

                         QList<Song*> songList = myLike->getAllSongs();
                         for (const auto &song :songList)
                         {
                            qDebug() << song->title();
                         }


                         // 重要：清理 Song 对象占用的内存。
                         // 接收列表的对象有责任清理它。
                         // qDeleteAll(foundSongs);
                         // scannerDir->m_foundSongs.clear(); // m_foundSongs是在MusicScanner内部管理的，外部不应直接清空

                         // 清理扫描器本身
                         // scannerDir->deleteLater();

                         // 所有工作都完成了，现在退出应用程序。
                         // QCoreApplication::quit();
                     });

    scannerDir->startScan(pathList);

    // QList<Song*> songs;
    // //遍历歌曲添加进songs列表
    // for (const QString &fileName : musicDir.entryList(QDir::Files)) {
    //     QString filePath = musicDir.absoluteFilePath(fileName);
    //     Song* song= new Song(filePath);
    //     if (song->loadMetadataFromFile()) {
    //         songs.append(song);
    //         // qDebug() << "添加: " << song->title();
    //     } else {
    //         qWarning() << "Failed to load metadata for:" << filePath;
    //     }
    // }

    // //遍历打印每首歌曲的信息
    // auto printSong = [](const Song &song) {
    //     qDebug() << "Title:" << song.title()
    //              << ", Artist:" << song.artist()
    //              << ", Album:" << song.album()
    //              << ", Duration:" << song.durationString()
    //              << ", File Path:" << song.filePath()
    //              << ", Cover Art Path:" << song.coverArtPath().toString()
    //              << ", Lyrics Path:" << song.lyricsPath();
    // };

    // for (const auto &song : songs) {
    //     qDebug() << song->title();
    //     qDebug() << song->artist();
    //     qDebug() << song->album() << "\n";
    //     // printSong(song);
    // }

    return app.exec();
}
