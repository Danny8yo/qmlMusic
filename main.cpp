#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include "PlayerController.h"
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
    //QString musicDir = "/home/lius/Music/no_cover_mp3s/";
    QString musicDir = "/root/Music";
    QStringList pathList;
    pathList.append(musicDir);
    // qDebug()<< pathList[0];
    Playlist *myLike = new Playlist("My Like");
    MusicScanner *scannerDir = new MusicScanner();
    // PlayerController *player = new PlayerController(&app);
    PlayerController *player = new PlayerController;
    scannerDir->startScan(pathList);
    QObject::connect(scannerDir,
                     &MusicScanner::scanFinished,
                     &app,
                     [scannerDir, myLike, player](const QList<Song *> &foundSongs) { // 使用值捕获
                         qDebug() << "\n--- 扫描完成！正在处理结果。 ---";
                         qDebug() << "最终歌曲数量:" << foundSongs.size();
                         qDebug() << "开始播放";

                         // 添加扫描到的歌曲到播放列表
                         for (const auto &song : foundSongs) {
                             myLike->addSong(song);
                         }

                         // 获取所有歌曲
                         QList<Song *> songList = myLike->getAllSongs();

                         // 打印歌曲信息
                         for (const auto &song : songList) {
                             qDebug() << song->title() << "-" << song->artist();
                         }

                         // playcontroller的部分功能测试（另一些功能想留在在ui界面进行测试）
                         // 加载到播放队列
                         player->loadQueue(songList);

                         // 连接播放器信号 - 使用捕获player指针
                         QObject::connect(player, &PlayerController::currentSongChanged, [player]() {
                             if (player->currentSong()) {
                                 qDebug() << "当前播放歌曲:" << player->currentSong()->title();
                             }
                         });

                         QObject::connect(player, &PlayerController::playbackStateChanged, [player]() {
                             qDebug() << "播放状态:" << player->playbackState();
                         });

                         // 开始播放
                         player->play();

                         // 定时器操作 - 使用捕获player指针
                         QTimer::singleShot(5000, player, [player]() {
                             player->pause();
                             qDebug() << "已暂停播放";

                             QTimer::singleShot(5000, player, [player]() {
                                 player->next();
                                 qDebug() << "跳到下一首";

                                 QTimer::singleShot(5000, player, [player]() {
                                     player->setPlaybackMode(PlayerController::Random);
                                     qDebug() << "设置随机播放模式";
                                     player->next();
                                 });
                             });
                         });
                     });

    // QGuiApplication app(argc, argv);

    // QQmlApplicationEngine engine;
    // QObject::connect(
    //     &engine,
    //     &QQmlApplicationEngine::objectCreationFailed,
    //     &app,
    //     []() { QCoreApplication::exit(-1); },
    //     Qt::QueuedConnection);
    // engine.loadFromModule("qmltest", "Main");

    // // 扫描/home/lius/Music/no_cover_mp3s/目录下的歌曲
    // //QString musicDir = "/home/lius/Music/no_cover_mp3s/";
    // QString musicDir = "/root/music/";
    // QStringList pathList;
    // pathList.append(musicDir);
    // // qDebug()<< pathList[0];
    // Playlist *myLike = new Playlist("My Like");
    // MusicScanner *scannerDir = new MusicScanner();

    // QObject::connect(scannerDir, &MusicScanner::scanFinished, &app,
    //                  [scannerDir,myLike](const QList<Song*>& foundSongs) {
    //                     //foundSongs 引用的是 MusicScanner 对象内部，通过 scanFinished 信号发出的那个列表。
    //                      qDebug() << "\n--- 扫描完成！正在处理结果。 ---";
    //                      qDebug() << "最终歌曲数量:" << foundSongs.size();

    //                      for (const auto &song : foundSongs)
    //                      {
    //                          myLike->addSong(song);
    //                      }

    //                      QList<Song*> songList = myLike->getAllSongs();
    //                      for (const auto &song :songList)
    //                      {
    //                          qDebug() << song->title() << song->artist();
    //                          //qDebug() << song->artist();
    //                      }

    //                      // 重要：清理 Song 对象占用的内存。
    //                      // 接收列表的对象有责任清理它。
    //                      // qDeleteAll(foundSongs);
    //                      // scannerDir->m_foundSongs.clear(); // m_foundSongs是在MusicScanner内部管理的，外部不应直接清空

    //                      // 清理扫描器本身
    //                      // scannerDir->deleteLater();

    //                      // 所有工作都完成了，现在退出应用程序。
    //                      // QCoreApplication::quit();
    //                  });

    // scannerDir->startScan(pathList);

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
