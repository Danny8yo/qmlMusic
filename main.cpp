#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // QQmlApplicationEngine engine;
    // QObject::connect(
    //     &engine,
    //     &QQmlApplicationEngine::objectCreationFailed,
    //     &app,
    //     []() { QCoreApplication::exit(-1); },
    //     Qt::QueuedConnection);
    // engine.loadFromModule("qmltest", "Main");

    //扫描/home/lius/Music/no_cover_mp3s/目录下的歌曲
    // QDir musicDir("/home/lius/Music/no_cover_mp3s/");
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
