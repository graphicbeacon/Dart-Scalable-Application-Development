// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of dart.io;

/**
 * The modes in which a File can be opened.
 */
class FileMode {
  /// The mode for opening a file only for reading.
  static const READ = const FileMode._internal(0);
  /// The mode for opening a file for reading and writing. The file is
  /// overwritten if it already exists. The file is created if it does not
  /// already exist.
  static const WRITE = const FileMode._internal(1);
  /// The mode for opening a file for reading and writing to the
  /// end of it. The file is created if it does not already exist.
  static const APPEND = const FileMode._internal(2);
  final int _mode;

  const FileMode._internal(this._mode);
}

/// The mode for opening a file only for reading.
const READ = FileMode.READ;
/// The mode for opening a file for reading and writing. The file is
/// overwritten if it already exists. The file is created if it does not
/// already exist.
const WRITE = FileMode.WRITE;
/// The mode for opening a file for reading and writing to the
/// end of it. The file is created if it does not already exist.
const APPEND = FileMode.APPEND;

/**
 * A reference to a file on the file system.
 *
 * A File instance is an object that holds a [path] on which operations can
 * be performed.
 * You can get the parent directory of the file using the getter [parent],
 * a property inherited from [FileSystemEntity].
 *
 * Create a new File object with a pathname to access the specified file on the
 * file system from your program.
 *
 *     var myFile = new File('file.txt');
 *
 * The File class contains methods for manipulating files and their contents.
 * Using methods in this class, you can open and close files, read to and write
 * from them, create and delete them, and check for their existence.
 *
 * When reading or writing a file, you can use streams (with [openRead]),
 * random access operations (with [open]),
 * or convenience methods such as [readAsString],
 *
 * Most methods in this class occur in synchronous and asynchronous pairs,
 * for example, [readAsString] and [readAsStringSync].
 * Unless you have a specific reason for using the synchronous version
 * of a method, prefer the asynchronous version to avoid blocking your program.
 *
 * ## If path is a link
 *
 * If [path] is a symbolic link, rather than a file,
 * then the methods of File operate on the ultimate target of the
 * link, except for [delete] and [deleteSync], which operate on
 * the link.
 *
 * ## Read from a file
 *
 * The following code sample reads the entire contents from a file as a string
 * using the asynchronous [readAsString] method:
 *
 *     import 'dart:async';
 *     import 'dart:io';
 *
 *     void main() {
 *       new File('file.txt').readAsString().then((String contents) {
 *         print(contents);
 *       });
 *     }
 *
 * A more flexible and useful way to read a file is with a [Stream].
 * Open the file with [openRead], which returns a stream that
 * provides the data in the file as chunks of bytes.
 * Listen to the stream for data and process as needed.
 * You can use various transformers in succession to manipulate the
 * data into the required format or to prepare it for output.
 *
 * You might want to use a stream to read large files,
 * to manipulate the data with tranformers,
 * or for compatibility with another API, such as [WebSocket]s.
 * 
 *     import 'dart:io';
 *     import 'dart:convert';
 *     import 'dart:async';
 *
 *     main() {
 *       final file = new File('file.txt');
 *       Stream<List<int>> inputStream = file.openRead();
 *
 *       inputStream
 *         .transform(UTF8.decoder)       // Decode bytes to UTF8.
 *         .transform(new LineSplitter()) // Convert stream to individual lines.
 *         .listen((String line) {        // Process results.
 *             print('$line: ${line.length} bytes');
 *           },
 *           onDone: () { print('File is now closed.'); },
 *           onError: (e) { print(e.toString()); });
 *     }
 *
 * ## Write to a file
 *
 * To write a string to a file, use the [writeAsString] method:
 *
 *     import 'dart:io';
 *
 *     void main() {
 *       final filename = 'file.txt';
 *       new File(filename).writeAsString('some content')
 *         .then((File file) {
 *           // Do something with the file.
 *         });
 *     }
 *
 * You can also write to a file using a [Stream]. Open the file with
 * [openWrite], which returns a stream to which you can write data.
 * Be sure to close the file with the [close] method.
 *
 *     import 'dart:io';
 *    
 *     void main() {
 *       var file = new File('file.txt');
 *       var sink = file.openWrite();
 *       sink.write('FILE ACCESSED ${new DateTime.now()}\n');
 *
 *       // Close the IOSink to free system resources.
 *       sink.close();
 *     }
 *
 * ## The use of Futures
 *
 * To avoid unintentional blocking of the program,
 * several methods use a [Future] to return a value. For example,
 * the [length] method, which gets the length of a file, returns a Future.
 * Use `then` to register a callback function, which is called when
 * the value is ready.
 *
 *     import 'dart:io';
 *
 *     main() {
 *       final file = new File('file.txt');
 *     
 *       file.length().then((len) {
 *         print(len);
 *       });
 *     }
 *
 * In addition to length, the [exists], [lastModified], [stat], and
 * other methods, return Futures.
 *
 * ## Other resources
 *
 * * [Dart by Example](https://www.dartlang.org/dart-by-example/#files-directories-and-symlinks)
 * provides additional task-oriented code samples that show how to use 
 * various API from the Directory class and the related [File] class.
 *
 * * [I/O for Command-Line Apps](https://www.dartlang.org/docs/dart-up-and-running/contents/ch03.html#ch03-dartio---file-and-socket-io-for-command-line-apps)
 * a section from _A Tour of the Dart Libraries_
 * covers files and directories.
 *
 * * [Write Command-Line Apps](https://www.dartlang.org/docs/tutorials/cmdline/),
 * a tutorial about writing command-line apps, includes information
 * about files and directories.

 */
abstract class File extends FileSystemEntity {
  /**
   * Create a File object.
   */
  factory File(String path) => new _File(path);

  /**
   * Create a File object from a URI.
   *
   * If [uri] cannot reference a file this throws [UnsupportedError].
   */
  factory File.fromUri(Uri uri) => new File(uri.toFilePath());

  /**
   * Create the file. Returns a [:Future<File>:] that completes with
   * the file when it has been created.
   *
   * If [recursive] is false, the default, the file is created only if
   * all directories in the path exist. If [recursive] is true, all
   * non-existing path components are created.
   *
   * Existing files are left untouched by [create]. Calling [create] on an
   * existing file might fail if there are restrictive permissions on
   * the file.
   *
   * Completes the future with a [FileSystemException] if the operation fails.
   */
  Future<File> create({bool recursive: false});

  /**
   * Synchronously create the file. Existing files are left untouched
   * by [createSync]. Calling [createSync] on an existing file might fail
   * if there are restrictive permissions on the file.
   *
   * If [recursive] is false, the default, the file is created
   * only if all directories in the path exist.
   * If [recursive] is true, all non-existing path components are created.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void createSync({bool recursive: false});

  /**
   * Renames this file. Returns a `Future<File>` that completes
   * with a [File] instance for the renamed file.
   *
   * If [newPath] identifies an existing file, that file is
   * replaced. If [newPath] identifies an existing directory, the
   * operation fails and the future completes with an exception.
   */
  Future<File> rename(String newPath);

   /**
   * Synchronously renames this file. Returns a [File]
   * instance for the renamed file.
   *
   * If [newPath] identifies an existing file, that file is
   * replaced. If [newPath] identifies an existing directory the
   * operation fails and an exception is thrown.
   */
  File renameSync(String newPath);

  /**
   * Copy this file. Returns a `Future<File>` that completes
   * with a [File] instance for the copied file.
   *
   * If [newPath] identifies an existing file, that file is
   * replaced. If [newPath] identifies an existing directory, the
   * operation fails and the future completes with an exception.
   */
  Future<File> copy(String newPath);

   /**
   * Synchronously copy this file. Returns a [File]
   * instance for the copied file.
   *
   * If [newPath] identifies an existing file, that file is
   * replaced. If [newPath] identifies an existing directory the
   * operation fails and an exception is thrown.
   */
  File copySync(String newPath);

  /**
   * Get the length of the file. Returns a [:Future<int>:] that
   * completes with the length in bytes.
   */
  Future<int> length();

  /**
   * Synchronously get the length of the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int lengthSync();

  /**
   * Returns a [File] instance whose path is the absolute path to [this].
   *
   * The absolute path is computed by prefixing
   * a relative path with the current working directory, and returning
   * an absolute path unchanged.
   */
  File get absolute;

  /**
   * Get the last-modified time of the file. Returns a
   * [:Future<DateTime>:] that completes with a [DateTime] object for the
   * modification date.
   */
  Future<DateTime> lastModified();

  /**
   * Get the last-modified time of the file. Throws an exception
   * if the file does not exist.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  DateTime lastModifiedSync();

  /**
   * Open the file for random access operations. Returns a
   * [:Future<RandomAccessFile>:] that completes with the opened
   * random access file. [RandomAccessFile]s must be closed using the
   * [RandomAccessFile.close] method.
   *
   * Files can be opened in three modes:
   *
   * [FileMode.READ]: open the file for reading.
   *
   * [FileMode.WRITE]: open the file for both reading and writing and
   * truncate the file to length zero. If the file does not exist the
   * file is created.
   *
   * [FileMode.APPEND]: same as [FileMode.WRITE] except that the file is
   * not truncated.
   */
  Future<RandomAccessFile> open({FileMode mode: FileMode.READ});

  /**
   * Synchronously open the file for random access operations. The
   * result is a [RandomAccessFile] on which random access operations
   * can be performed. Opened [RandomAccessFile]s must be closed using
   * the [RandomAccessFile.close] method.
   *
   * See [open] for information on the [mode] argument.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  RandomAccessFile openSync({FileMode mode: FileMode.READ});

  /**
   * Create a new independent [Stream] for the contents of this file.
   *
   * If [start] is present, the file will be read from byte-offset [start].
   * Otherwise from the beginning (index 0).
   *
   * If [end] is present, only up to byte-index [end] will be read. Otherwise,
   * until end of file.
   *
   * In order to make sure that system resources are freed, the stream
   * must be read to completion or the subscription on the stream must
   * be cancelled.
   */
  Stream<List<int>> openRead([int start, int end]);

  /**
   * Creates a new independent [IOSink] for the file. The
   * [IOSink] must be closed when no longer used, to free
   * system resources.
   *
   * An [IOSink] for a file can be opened in two modes:
   *
   * * [FileMode.WRITE]: truncates the file to length zero.
   * * [FileMode.APPEND]: sets the initial write position to the end
   *   of the file.
   *
   *  When writing strings through the returned [IOSink] the encoding
   *  specified using [encoding] will be used. The returned [IOSink]
   *  has an [:encoding:] property which can be changed after the
   *  [IOSink] has been created.
   */
  IOSink openWrite({FileMode mode: FileMode.WRITE,
                    Encoding encoding: UTF8});

  /**
   * Read the entire file contents as a list of bytes. Returns a
   * [:Future<List<int>>:] that completes with the list of bytes that
   * is the contents of the file.
   */
  Future<List<int>> readAsBytes();

  /**
   * Synchronously read the entire file contents as a list of bytes.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  List<int> readAsBytesSync();

  /**
   * Read the entire file contents as a string using the given
   * [Encoding].
   *
   * Returns a [:Future<String>:] that completes with the string once
   * the file contents has been read.
   */
  Future<String> readAsString({Encoding encoding: UTF8});

  /**
   * Synchronously read the entire file contents as a string using the
   * given [Encoding].
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  String readAsStringSync({Encoding encoding: UTF8});

  /**
   * Read the entire file contents as lines of text using the given
   * [Encoding].
   *
   * Returns a [:Future<List<String>>:] that completes with the lines
   * once the file contents has been read.
   */
  Future<List<String>> readAsLines({Encoding encoding: UTF8});

  /**
   * Synchronously read the entire file contents as lines of text
   * using the given [Encoding].
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  List<String> readAsLinesSync({Encoding encoding: UTF8});

  /**
   * Write a list of bytes to a file.
   *
   * Opens the file, writes the list of bytes to it, and closes the file.
   * Returns a [:Future<File>:] that completes with this [File] object once
   * the entire operation has completed.
   *
   * By default [writeAsBytes] creates the file for writing and truncates the
   * file if it already exists. In order to append the bytes to an existing
   * file, pass [FileMode.APPEND] as the optional mode parameter.
   *
   * If the argument [flush] is set to `true`, the data written will be
   * flushed to the file system before the returned future completes.
   */
  Future<File> writeAsBytes(List<int> bytes,
                            {FileMode mode: FileMode.WRITE,
                             bool flush: false});

  /**
   * Synchronously write a list of bytes to a file.
   *
   * Opens the file, writes the list of bytes to it and closes the file.
   *
   * By default [writeAsBytesSync] creates the file for writing and truncates
   * the file if it already exists. In order to append the bytes to an existing
   * file, pass [FileMode.APPEND] as the optional mode parameter.
   *
   * If the [flush] argument is set to `true` data written will be
   * flushed to the file system before returning.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void writeAsBytesSync(List<int> bytes,
                        {FileMode mode: FileMode.WRITE,
                         bool flush: false});

  /**
   * Write a string to a file.
   *
   * Opens the file, writes the string in the given encoding, and closes the
   * file. Returns a [:Future<File>:] that completes with this [File] object
   * once the entire operation has completed.
   *
   * By default [writeAsString] creates the file for writing and truncates the
   * file if it already exists. In order to append the bytes to an existing
   * file, pass [FileMode.APPEND] as the optional mode parameter.
   *
   * If the argument [flush] is set to `true`, the data written will be
   * flushed to the file system before the returned future completes.
   *
   */
  Future<File> writeAsString(String contents,
                             {FileMode mode: FileMode.WRITE,
                              Encoding encoding: UTF8,
                              bool flush: false});

  /**
   * Synchronously write a string to a file.
   *
   * Opens the file, writes the string in the given encoding, and closes the
   * file.
   *
   * By default [writeAsStringSync] creates the file for writing and
   * truncates the file if it already exists. In order to append the bytes
   * to an existing file, pass [FileMode.APPEND] as the optional mode
   * parameter.
   *
   * If the [flush] argument is set to `true` data written will be
   * flushed to the file system before returning.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void writeAsStringSync(String contents,
                         {FileMode mode: FileMode.WRITE,
                          Encoding encoding: UTF8,
                          bool flush: false});

  /**
   * Get the path of the file.
   */
  String get path;
}


/**
 * [RandomAccessFile] provides random access to the data in a
 * file. [RandomAccessFile] objects are obtained by calling the
 * [:open:] method on a [File] object.
 */
abstract class RandomAccessFile {
  /**
   * Closes the file. Returns a [:Future<RandomAccessFile>:] that
   * completes with this RandomAccessFile when it has been closed.
   */
  Future<RandomAccessFile> close();

  /**
   * Synchronously closes the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void closeSync();

  /**
   * Reads a byte from the file. Returns a [:Future<int>:] that
   * completes with the byte, or with -1 if end-of-file has been reached.
   */
  Future<int> readByte();

  /**
   * Synchronously reads a single byte from the file. If end-of-file
   * has been reached -1 is returned.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int readByteSync();

  /**
   * Reads [bytes] bytes from a file and returns the result as a list of bytes.
   */
  Future<List<int>> read(int bytes);

  /**
   * Synchronously reads a maximum of [bytes] bytes from a file and
   * returns the result in a list of bytes.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  List<int> readSync(int bytes);

  /**
   * Reads into an existing List<int> from the file. If [start] is present, the
   * bytes will be filled into [buffer] from at index [start], otherwise index
   * 0. If [end] is present, the [end] - [start] bytes will be read into
   * [buffer], otherwise up to [buffer.length]. If [end] == [start] nothing
   * happends.
   *
   * Returns a [:Future<int>:] that completes with the number of bytes read.
   */
  Future<int> readInto(List<int> buffer, [int start, int end]);

  /**
   * Synchronously reads into an existing List<int> from the file. If [start] is
   * present, the bytes will be filled into [buffer] from at index [start],
   * otherwise index 0.  If [end] is present, the [end] - [start] bytes will be
   * read into [buffer], otherwise up to [buffer.length]. If [end] == [start]
   * nothing happends.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int readIntoSync(List<int> buffer, [int start, int end]);

  /**
   * Writes a single byte to the file. Returns a
   * [:Future<RandomAccessFile>:] that completes with this
   * RandomAccessFile when the write completes.
   */
  Future<RandomAccessFile> writeByte(int value);

  /**
   * Synchronously writes a single byte to the file. Returns the
   * number of bytes successfully written.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int writeByteSync(int value);

  /**
   * Writes from a [List<int>] to the file. It will read the buffer from index
   * [start] to index [end]. If [start] is omitted, it'll start from index 0.
   * If [end] is omitted, it will write to end of [buffer].
   *
   * Returns a [:Future<RandomAccessFile>:] that completes with this
   * [RandomAccessFile] when the write completes.
   */
  Future<RandomAccessFile> writeFrom(List<int> buffer, [int start, int end]);

  /**
   * Synchronously writes from a [List<int>] to the file. It will read the
   * buffer from index [start] to index [end]. If [start] is omitted, it'll
   * start from index 0. If [end] is omitted, it will write to the end of
   * [buffer].
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void writeFromSync(List<int> buffer, [int start, int end]);

  /**
   * Writes a string to the file using the given [Encoding]. Returns a
   * [:Future<RandomAccessFile>:] that completes with this
   * RandomAccessFile when the write completes.
   */
  Future<RandomAccessFile> writeString(String string,
                                       {Encoding encoding: UTF8});

  /**
   * Synchronously writes a single string to the file using the given
   * [Encoding].
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void writeStringSync(String string,
                       {Encoding encoding: UTF8});

  /**
   * Gets the current byte position in the file. Returns a
   * [:Future<int>:] that completes with the position.
   */
  Future<int> position();

  /**
   * Synchronously gets the current byte position in the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int positionSync();

  /**
   * Sets the byte position in the file. Returns a
   * [:Future<RandomAccessFile>:] that completes with this
   * RandomAccessFile when the position has been set.
   */
  Future<RandomAccessFile> setPosition(int position);

  /**
   * Synchronously sets the byte position in the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void setPositionSync(int position);

  /**
   * Truncates (or extends) the file to [length] bytes. Returns a
   * [:Future<RandomAccessFile>:] that completes with this
   * RandomAccessFile when the truncation has been performed.
   */
  Future<RandomAccessFile> truncate(int length);

  /**
   * Synchronously truncates (or extends) the file to [length] bytes.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void truncateSync(int length);

  /**
   * Gets the length of the file. Returns a [:Future<int>:] that
   * completes with the length in bytes.
   */
  Future<int> length();

  /**
   * Synchronously gets the length of the file.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  int lengthSync();

  /**
   * Flushes the contents of the file to disk. Returns a
   * [:Future<RandomAccessFile>:] that completes with this
   * RandomAccessFile when the flush operation completes.
   */
  Future<RandomAccessFile> flush();

  /**
   * Synchronously flushes the contents of the file to disk.
   *
   * Throws a [FileSystemException] if the operation fails.
   */
  void flushSync();

  /**
   * Returns a human-readable string for this RandomAccessFile instance.
   */
  String toString();

  /**
   * Gets the path of the file underlying this RandomAccessFile.
   */
  String get path;
}


/**
 * Exception thrown when a file operation fails.
 */
class FileSystemException implements IOException {
  /**
   * Message describing the error. This does not include any detailed
   * information form the underlying OS error. Check [osError] for
   * that information.
   */
  final String message;

  /**
   * The file system path on which the error occurred. Can be `null`
   * if the exception does not relate directly to a file system path.
   */
  final String path;

  /**
   * The underlying OS error. Can be `null` if the exception is not
   * raised due to an OS error.
   */
  final OSError osError;

  /**
   * Creates a new FileSystemException with an optional error message
   * [message], optional file system path [path] and optional OS error
   * [osError].
   */
  const FileSystemException([this.message = "", this.path = "", this.osError]);

  String toString() {
    StringBuffer sb = new StringBuffer();
    sb.write("FileSystemException");
    if (!message.isEmpty) {
      sb.write(": $message");
      if (path != null) {
        sb.write(", path = '$path'");
      }
      if (osError != null) {
        sb.write(" ($osError)");
      }
    } else if (osError != null) {
      sb.write(": $osError");
      if (path != null) {
        sb.write(", path = '$path'");
      }
    } else if (path != null) {
      sb.write(": $path");
    }
    return sb.toString();
  }
}
