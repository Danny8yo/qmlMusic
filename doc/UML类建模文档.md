# QML Music Player - UML类建模文档

## 1. 系统架构概览

QML Music Player采用分层架构设计，主要分为表示层(QML UI)、业务逻辑层(C++ Backend)和数据访问层(SQLite Database)。

## 2. 核心类设计

### 2.1 整体类关系图

```mermaid
classDiagram
    class BackendManager {
        -static BackendManager* instance
        -SongModel* m_songModel
        -SongModel* m_favoriteModel
        -LocalSongModel* m_localSongModel
        -PlaylistModel* m_playlistModel
        -PlaylistModel* m_locallistModel
        -PlayerController* m_playerController
        -DatabaseManager* m_dbManager
        -MusicScanner* m_scanner
        -LyricsExtractor* m_lyricsExtractor
        +getInstance() BackendManager*
        +initialize() bool
        +scanMusicLibrary(QStringList)
        +playSongById(int)
        +playPlaylist(int)
        +getSongById(int) Song*
        +getPlaylistById(int) Playlist*
        +addSongToPlaylist(Song*, Playlist*)
        +setSongFavorite(Song*, bool)
        +createPlaylist(QString) Playlist*
        +deletePlaylist(int)
    }

    class Song {
        -int m_id
        -QString m_title
        -QString m_artist
        -QString m_album
        -int m_duration
        -QString m_filePath
        -QUrl m_coverArtUrl
        -QString m_lyricsPath
        -bool m_isFavorite
        +Song(QString, QString, int, QString, QString, int)
        +loadMetadataFromFile() bool
        +id() int
        +title() QString
        +artist() QString
        +album() QString
        +duration() int
        +filePath() QString
        +isFavorite() bool
        +setId(int)
        +setTitle(QString)
        +setArtist(QString)
        +setAlbum(QString)
        +setDuration(int)
        +setFilePath(QString)
        +setIsFavorite(bool)
        +durationString() QString
    }

    class Playlist {
        -int m_id
        -QString m_name
        -QString m_description
        -QList~Song*~ m_songs
        -bool m_isLocal
        +Playlist(QString, QObject*)
        +id() int
        +name() QString
        +description() QString
        +songs() QList~Song*~
        +isLocal() bool
        +setId(int)
        +setName(QString)
        +setDescription(QString)
        +setIsLocal(bool)
        +addSong(Song*)
        +removeSong(Song*)
        +removeSongAt(int)
        +clearSongs()
        +songCount() int
        +contains(Song*) bool
    }

    class SongModel {
        -QList~Song*~ m_songs
        +SongModel(QObject*)
        +rowCount(QModelIndex) int
        +data(QModelIndex, int) QVariant
        +roleNames() QHash~int, QByteArray~
        +songs() QList~Song*~
        +addSong(Song*)
        +removeSong(Song*)
        +removeSongAt(int)
        +clear()
        +getSongById(int) Song*
        +getSongByIndex(int) Song*
        +updateSong(Song*)
    }

    class PlaylistModel {
        -QList~Playlist*~ m_playlists
        +PlaylistModel(QObject*)
        +rowCount(QModelIndex) int
        +data(QModelIndex, int) QVariant
        +roleNames() QHash~int, QByteArray~
        +playlists() QList~Playlist*~
        +addPlaylist(Playlist*)
        +removePlaylist(Playlist*)
        +removePlaylistAt(int)
        +clear()
        +getPlaylistById(int) Playlist*
        +getPlaylistByIndex(int) Playlist*
    }

    class LocalSongModel {
        +LocalSongModel(QObject*)
        +setFilterPattern(QString)
        +clearFilter()
    }

    class PlayerController {
        -QMediaPlayer* m_player
        -QAudioOutput* m_audioOutput
        -QList~Song*~ m_playlist
        -int m_currentIndex
        -PlayMode m_playMode
        -bool m_isPlaying
        -qint64 m_position
        -qint64 m_duration
        -float m_volume
        +PlayerController(QObject*)
        +play()
        +pause()
        +stop()
        +next()
        +previous()
        +setPlaylist(QList~Song*~)
        +setCurrentIndex(int)
        +setPosition(qint64)
        +setVolume(float)
        +setPlayMode(PlayMode)
        +isPlaying() bool
        +currentSong() Song*
        +position() qint64
        +duration() qint64
        +volume() float
    }

    class DatabaseManager {
        -QSqlDatabase m_db
        -QString m_dbPath
        +DatabaseManager(QString, QObject*)
        +initialize() bool
        +addSong(Song*) bool
        +removeSong(int) bool
        +updateSong(Song*) bool
        +getSongById(int) Song*
        +getAllSongs() QList~Song*~
        +addPlaylist(Playlist*) bool
        +removePlaylist(int) bool
        +updatePlaylist(Playlist*) bool
        +getPlaylistById(int) Playlist*
        +getAllPlaylists() QList~Playlist*~
        +addSongToPlaylist(int, int) bool
        +removeSongFromPlaylist(int, int) bool
        +setSongFavorite(int, bool) bool
        +getFavoriteSongs() QList~Song*~
    }

    class MusicScanner {
        -QStringList m_supportedFormats
        -bool m_isScanning
        +MusicScanner(QObject*)
        +scanDirectories(QStringList)
        +stopScanning()
        +getSupportedFormats() QStringList
        +isScanning() bool
        -scanDirectory(QString) QList~Song*~
        -isSupportedFormat(QString) bool
    }

    class LyricsExtractor {
        +LyricsExtractor(QObject*)
        +extractLyrics(Song*) QString
        +loadLyricsFromFile(QString) QStringList
        +parseLrcFormat(QString) QList~LyricLine~
        +getCurrentLyric(qint64) QString
    }

    %% 关系定义
    BackendManager --> SongModel : manages
    BackendManager --> PlaylistModel : manages  
    BackendManager --> LocalSongModel : manages
    BackendManager --> PlayerController : manages
    BackendManager --> DatabaseManager : manages
    BackendManager --> MusicScanner : manages
    BackendManager --> LyricsExtractor : manages

    SongModel --> Song : contains
    PlaylistModel --> Playlist : contains
    LocalSongModel --|> SongModel : inherits

    Playlist --> Song : contains
    PlayerController --> Song : plays

    DatabaseManager ..> Song : persists
    DatabaseManager ..> Playlist : persists

    MusicScanner ..> Song : discovers
    LyricsExtractor ..> Song : extracts_lyrics
```

### 2.2 数据模型类详细设计

#### 2.2.1 Song类设计

```mermaid
classDiagram
    class Song {
        <<QObject>>
        -int m_id
        -QString m_title
        -QString m_artist 
        -QString m_album
        -int m_duration
        -QString m_filePath
        -QUrl m_coverArtUrl
        -QString m_lyricsPath
        -bool m_isFavorite

        +Song(filePath: QString, parent: QObject*)
        +Song(filePath: QString, title: QString, id: int, artist: QString, album: QString, duration: int, parent: QObject*)
        +Song(parent: QObject*)

        +loadMetadataFromFile(): bool

        +id(): int
        +title(): QString  
        +artist(): QString
        +album(): QString
        +duration(): int
        +filePath(): QString
        +coverArtUrl(): QUrl
        +lyricsPath(): QString
        +durationString(): QString
        +isFavorite(): bool

        +setId(id: int): void
        +setTitle(title: QString): void
        +setArtist(artist: QString): void
        +setAlbum(album: QString): void
        +setDuration(duration: int): void
        +setFilePath(filePath: QString): void
        +setCoverArtUrl(url: QUrl): void
        +setLyricsPath(path: QString): void
        +setIsFavorite(favorite: bool): void

        <<signal>> idChanged()
        <<signal>> titleChanged()
        <<signal>> artistChanged()
        <<signal>> albumChanged()
        <<signal>> durationChanged()
        <<signal>> filePathChanged()
        <<signal>> coverArtUrlChanged()
        <<signal>> lyricsPathChanged()
        <<signal>> favoriteChanged()
    }


```

#### 2.2.2 Playlist类设计

```mermaid
classDiagram
    class Playlist {
        <<QObject>>
        -int m_id
        -QString m_name
        -QString m_description
        -QList~Song*~ m_songs
        -bool m_isLocal

        +Playlist(name: QString, parent: QObject*)
        +Playlist(parent: QObject*)

        +id(): int
        +name(): QString
        +description(): QString  
        +songs(): QList~Song*~
        +isLocal(): bool
        +songCount(): int

        +setId(id: int): void
        +setName(name: QString): void
        +setDescription(description: QString): void
        +setIsLocal(isLocal: bool): void

        +addSong(song: Song*): void
        +removeSong(song: Song*): void
        +removeSongAt(index: int): void
        +clearSongs(): void
        +contains(song: Song*): bool
        +indexOf(song: Song*): int

        <<signal>> idChanged()
        <<signal>> nameChanged()
        <<signal>> descriptionChanged()
        <<signal>> songsChanged()
        <<signal>> isLocalChanged()
        <<signal>> songAdded(Song*)
        <<signal>> songRemoved(Song*)
    }

    Playlist --> Song : contains
```

### 2.3 业务逻辑层类设计

#### 2.3.1 BackendManager类设计

```mermaid
classDiagram
    class BackendManager {
        <<QObject, Singleton>>
        -static BackendManager* s_instance
        -SongModel* m_songModel
        -SongModel* m_favoriteModel
        -LocalSongModel* m_localSongModel
        -PlaylistModel* m_playlistModel
        -PlaylistModel* m_locallistModel
        -PlayerController* m_playerController
        -DatabaseManager* m_dbManager
        -MusicScanner* m_scanner
        -LyricsExtractor* m_lyricsExtractor
        -QString m_appDir

        +BackendManager(parent: QObject*)
        +instance(): BackendManager*
        +create(engine: QQmlEngine*, scriptEngine: QJSEngine*): BackendManager*

        +initialize(): bool

        +songModel(): SongModel*
        +favoriteModel(): SongModel* 
        +localSongModel(): LocalSongModel*
        +playlistModel(): PlaylistModel*
        +locallistModel(): PlaylistModel*
        +playerController(): PlayerController*
        +lyricsExtractor(): LyricsExtractor*
        +appDirPath(): QString

        +scanMusicLibrary(directories: QStringList): void
        +playSongById(songId: int): void
        +playPlaylist(playlistId: int): void
        +playPlaylist(favoritelist: QList~Song*~): void

        +getSongById(songId: int): Song*
        +getPlaylistById(playlistId: int): Playlist*
        +getPlaylistByIndex(index: int): Playlist*
        +getLocalPlaylistById(playlistId: int): Playlist*
        +getLocalPlaylistByIndex(index: int): Playlist*

        +addSongToPlaylist(song: Song*, playlist: Playlist*): void
        +removeSongFromPlaylist(song: Song*, playlist: Playlist*): void
        +setSongFavorite(song: Song*, favorite: bool): void

        +createPlaylist(name: QString): Playlist*
        +deletePlaylist(playlistId: int): void
        +deleteLocalPlaylist(playlistId: int): void

        <<signal>> songFavoriteChanged(song: Song*, isFavorite: bool)
        <<signal>> scanProgress(progress: int)
        <<signal>> scanCompleted()

        -onScanCompleted(songs: QList~Song*~): void
        -loadFavoriteSongs(): void
        -loadPlaylists(): void
    }
```

#### 2.3.2 PlayerController类设计

```mermaid
classDiagram
    class PlayerController {
        <<QObject>>

        -QMediaPlayer* m_player
        -QAudioOutput* m_audioOutput
        -QList~Song*~ m_playlist
        -int m_currentIndex  
        -PlayMode m_playMode
        -bool m_isPlaying
        -qint64 m_position
        -qint64 m_duration
        -float m_volume

        +PlayerController(parent: QObject*)

        +play(): void
        +pause(): void  
        +stop(): void
        +next(): void
        +previous(): void
        +togglePlayPause(): void

        +setPlaylist(playlist: QList~Song*~): void
        +setCurrentIndex(index: int): void
        +setPosition(position: qint64): void
        +setVolume(volume: float): void
        +setPlayMode(mode: PlayMode): void

        +isPlaying(): bool
        +currentSong(): Song*
        +position(): qint64
        +duration(): qint64
        +volume(): float
        +playMode(): PlayMode
        +currentIndex(): int
        +playlist(): QList~Song*~

        <<signal>> isPlayingChanged()
        <<signal>> currentSongChanged()  
        <<signal>> positionChanged()
        <<signal>> durationChanged()
        <<signal>> volumeChanged()
        <<signal>> playModeChanged()
        <<signal>> currentIndexChanged()

        -onMediaStatusChanged(status: QMediaPlayer::MediaStatus): void
        -onPositionChanged(position: qint64): void
        -onDurationChanged(duration: qint64): void
        -playCurrentSong(): void
    }

    class PlayMode {
        <<enumeration>>
        Sequential
        Loop
        Random
        CurrentItemOnce
        CurrentItemInLoop
    }

    PlayerController --> PlayMode : uses
    PlayerController --> Song : manages
```

### 2.4 数据访问层类设计

#### 2.4.1 DatabaseManager类设计

```mermaid
classDiagram
    class DatabaseManager {
        <<QObject>>
        -QSqlDatabase m_db
        -QString m_dbPath

        +DatabaseManager(dbPath: QString, parent: QObject*)

        +initialize(): bool
        +isInitialized(): bool

        +addSong(song: Song*): bool
        +removeSong(songId: int): bool  
        +updateSong(song: Song*): bool
        +getSongById(songId: int): Song*
        +getAllSongs(): QList~Song*~
        +getSongsByArtist(artist: QString): QList~Song*~
        +getSongsByAlbum(album: QString): QList~Song*~

        +addPlaylist(playlist: Playlist*): bool
        +removePlaylist(playlistId: int): bool
        +updatePlaylist(playlist: Playlist*): bool  
        +getPlaylistById(playlistId: int): Playlist*
        +getAllPlaylists(): QList~Playlist*~
        +getLocalPlaylists(): QList~Playlist*~

        +addSongToPlaylist(songId: int, playlistId: int): bool
        +removeSongFromPlaylist(songId: int, playlistId: int): bool
        +getPlaylistSongs(playlistId: int): QList~Song*~

        +setSongFavorite(songId: int, favorite: bool): bool
        +getFavoriteSongs(): QList~Song*~

        -createTables(): bool
        -songFromQuery(query: QSqlQuery): Song*
        -playlistFromQuery(query: QSqlQuery): Playlist*
        -executeQuery(queryStr: QString, params: QVariantList): bool
    }
```

#### 2.4.2 MusicScanner类设计

```mermaid
classDiagram
    class MusicScanner {
        <<QObject>>
        -QStringList m_supportedFormats
        -bool m_isScanning
        -QThread* m_scanThread

        +MusicScanner(parent: QObject*)

        +scanDirectories(directories: QStringList): void
        +stopScanning(): void
        +getSupportedFormats(): QStringList
        +isScanning(): bool

        <<signal>> scanProgress(progress: int)
        <<signal>> scanCompleted(songs: QList~Song*~)
        <<signal>> scanStarted()
        <<signal>> scanStopped()

        -scanDirectory(dirPath: QString): QList~Song*~
        -scanFile(filePath: QString): Song*
        -isSupportedFormat(filePath: QString): bool
        -extractMetadata(filePath: QString): Song*
    }
```

### 2.5 QML界面组件设计

#### 2.5.1 主要QML组件关系

```mermaid
classDiagram
    class Main {
        <<QML Window>>
        +stack: StackView
        +lyricsComponent: Component
        +playQueueComponent: Component
    }

    class MusicUi {
        <<QML Item>>
        +currentPage: string
        +selectedPlaylistId: int
        +navigateToPage(pageName, addToHistory, playlistId)
        +goBack()
    }

    class LeftGuideBar {
        <<QML Item>>
        <<signal>> navigationRequested(page)
        <<signal>> mylistRequested(playlistId)
    }

    class TopBar {
        <<QML Item>>
        <<signal>> backRequested()
        <<signal>> forwardRequested()
        +updateNavigationButtons()
    }

    class PlayController {
        <<QML Item>>
        +playerController: PlayerController
        +currentSong: Song
    }

    class Local {
        <<QML Item>>
        +localSongModel: LocalSongModel
    }

    class PlaylistView {
        <<QML Item>>
        +playlist: Playlist
        +playlistId: int
    }

    class MyFavoritesView {
        <<QML Item>>
        +favoriteModel: SongModel
    }

    class SongView {
        <<QML Item>>
        +songModel: SongModel
    }

    class Lyrics {
        <<QML Item>>
        +lyricsExtractor: LyricsExtractor
        +currentSong: Song
    }

    Main --> MusicUi : contains
    MusicUi --> LeftGuideBar : contains
    MusicUi --> TopBar : contains
    Main --> PlayController : contains

    MusicUi --> Local : loads
    MusicUi --> PlaylistView : loads  
    MusicUi --> MyFavoritesView : loads
    MusicUi --> SongView : loads
    Main --> Lyrics : loads
```

## 3. 设计模式应用

### 3.1 单例模式 (Singleton Pattern)

- **应用类**: `BackendManager`
- **目的**: 确保整个应用只有一个后端管理器实例，提供全局访问点
- **实现**: 静态实例变量 + 私有构造函数 + 公共getInstance方法

### 3.2 模型-视图模式 (Model-View Pattern)

- **应用类**: `SongModel`, `PlaylistModel`, `LocalSongModel`
- **目的**: 分离数据模型和UI视图，支持数据绑定和自动更新
- **实现**: 继承QAbstractListModel，实现Qt的模型-视图框架

### 3.3 观察者模式 (Observer Pattern)

- **应用**: Qt信号-槽机制
- **目的**: 实现组件间的松耦合通信
- **实现**: Q_SIGNAL和Q_SLOT宏，connect函数连接

### 3.4 外观模式 (Facade Pattern)

- **应用类**: `BackendManager`  
- **目的**: 为复杂的后端子系统提供统一的简化接口
- **实现**: BackendManager封装所有子模块，QML只需与其交互

### 3.5 策略模式 (Strategy Pattern)

- **应用**: 播放模式切换
- **目的**: 动态切换不同的播放策略(顺序、随机、循环等)
- **实现**: PlayMode枚举 + PlayerController中的策略切换逻辑

---