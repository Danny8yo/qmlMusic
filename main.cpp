
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include "PlayerController.h"
#include "MusicScanner.h"
#include "playlist.h"
#include "backendmanager.h"
#include "song.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 注册Song类
    qmlRegisterType<Song>("Song", 1, 0, "Song");

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
    QString musicDir = "/root/qmlMusic-dev/qmlMusic/Local_Playlist";
    QStringList pathList;
    pathList.append(musicDir);

    // backendmanager测试
    BackendManager *backend = BackendManager::instance();

    //
    if (!backend->initialize()) {
        qCritical() << "Failed to initialize BackendManager";
        return -1;
    }
    // // qDebug()<< pathList[0];
    // Playlist *myLike = new Playlist("My Like");
    // MusicScanner *scannerDir = new MusicScanner();
    // // PlayerController *player = new PlayerController(&app);
    // PlayerController *player = new PlayerController;
    // scannerDir->startScan(pathList);
    // QObject::connect(scannerDir,
    //                  &MusicScanner::scanFinished,
    //                  &app,
    //                  [scannerDir, myLike, player](const QList<Song *> &foundSongs) { // 使用值捕获
    //                      qDebug() << "\n--- 扫描完成！正在处理结果。 ---";
    //                      qDebug() << "最终歌曲数量:" << foundSongs.size();
    //                      qDebug() << "开始播放";

    //                      // 添加扫描到的歌曲到播放列表
    //                      for (const auto &song : foundSongs) {
    //                          myLike->addSong(song);
    //                      }

    //                      // 获取所有歌曲
    //                      QList<Song *> songList = myLike->getAllSongs();

    //                      // 打印歌曲信息
    //                      for (const auto &song : songList) {
    //                          qDebug() << song->title() << "-" << song->artist() << song->coverArtPath();
    //                      }

    //                      // 加载到播放队列
    //                      player->loadQueue(songList);

    //                      // 连接播放器信号 - 使用捕获player指针
    //                      QObject::connect(player, &PlayerController::currentSongChanged, [player]() {
    //                          if (player->currentSong()) {
    //                              qDebug() << "当前播放歌曲:" << player->currentSong()->title();
    //                          }
    //                      });

    //                      QObject::connect(player, &PlayerController::playbackStateChanged, [player]() {
    //                          qDebug() << "播放状态:" << player->playbackState();
    //                      });

    //                      // 开始播放
    //                      player->play();

    //                      // 定时器操作 - 使用捕获player指针
    //                      QTimer::singleShot(5000, player, [player]() {
    //                          player->pause();
    //                          qDebug() << "已暂停播放";

    //                          QTimer::singleShot(5000, player, [player]() {
    //                              player->next();
    //                              qDebug() << "跳到下一首";

    //                              QTimer::singleShot(5000, player, [player]() {
    //                                  player->setPlaybackMode(PlayerController::Random);
    //                                  qDebug() << "设置随机播放模式";
    //                                  player->next();
    //                              });
    //                          });
    //                      });
    //                  });
    return app.exec();
}
