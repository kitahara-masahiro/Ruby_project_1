# -*- coding: utf-8 -*-
require 'date'

class BookInfo
  # BookInfoクラスのインスタンスを初期化する
  def initialize( title, author, page, publish_date )
    @title = title
    @author = author
    @page = page
    @publish_date = publish_date
  end

  # 最初に検討する属性に対するアクセサを提供する
  attr_accessor :title, :author, :page, :publish_date

  # BookInfoクラスのインスタンスをcsv形式へ変換する
  def to_csv(key)
    "#{key},#{@title},#{@author},#{@page},#{@publish_date}\n"
  end

  # BookInfoクラスのインスタンスの文字列表現を返す
  def to_s
    "#{@title}, #{@author}, #{@page}, #{@publish_date}"
  end

  # 蔵書データを書式を付けて出力する操作を追加
  # 項目の区切り文字を引数に指定することができる
  # 引数を省略した場合は改行を区切り文字にする
  def to_formatted_string( sep = "\n" )
    "書籍名： #{@title}#{sep}著者名： #{@author}#{sep}ページ数： #{@page}ページ#{sep}発行日： #{@publish_date}#{sep}"
  end
end

class BookInfoManager
  def initialize(filename)
    # 初期化でcsvファイルを指定する
    @csv_file_name = filename
    # 蔵書データのハッシュ
    @book_infos = {}
  end

  # 蔵書データをセットアップする
  def set_up
    # csvファイルを読み込みモードでオープンする
    open(@csv_file_name, "r:UTF-8") {|file|
      # ファイルの行を1行ずつ取り出して、lineに読み込む
      file.each {|line|
        # lineからchompで改行を除き、splitでカンマ区切りに分割し、左辺のそれぞれの項目へ多重代入する
        key, title, author, page, publish_date = line.chomp.split(',')
        # 蔵書データ1件分のインスタンスを作成してハッシュに登録する
        # strptimeは、文字列からDateクラスのインスタンスを作成するメソッド
        @book_infos[key] = BookInfo.new(title, author, page.to_i, Date.strptime(publish_date))
      }
    } # ファイルが閉じられる
  end

  # 蔵書データを登録する
  def add_book_info
    # 蔵書データ1件分のインスタンスを作成する
    book_info = BookInfo.new( "", "", 0, Date.new )

    # 登録するデータを項目ごとに入力する
    print "\n"
    print "登録コード： "
    key = gets.chomp
    print "書籍名： "
    book_info.title = gets.chomp
    print "著者名： "
    book_info.author = gets.chomp
    print "ページ数： "
    book_info.page = gets.chomp.to_i
    print "発行年： "
    year = gets.chomp.to_i
    print "発行月： "
    month = gets.chomp.to_i
    print "発行日： "
    date = gets.chomp.to_i
    if year == 0 && month == 0 && date == 0 then
      book_info.publish_date = nil
    else
      book_info.publish_date = Date.new( year, month, date )
    end

    # 作成した蔵書データの1件分をハッシュに登録する
    if book_info.title != "" then
      @book_infos[key] = book_info
    end

  end

  # 蔵書データの一覧を表示する
  def list_all_book_infos
    puts "\n------------------------------------------------------------------"
    @book_infos.each { |key, info|
      print info.to_formatted_string
      puts "\n------------------------------------------------------------------"
    }
  end

  # 検索したい語句を入力する
  def input
    # 蔵書データ1件分のインスタンスを作成する
    @search_term = BookInfo.new( "", "", 0, Date.new )

    # 検索するデータを項目ごとに入力する
    puts ""
    puts "**********************************"
    puts "検索したい語句を入力してください。"
    print "書籍名： "
    @search_term.title = gets.chomp.to_s
    print "著者名： "
    @search_term.author = gets.chomp.to_s
    print "ページ数： "
    @search_term.page = gets.chomp.to_i
    print "発行年： "
    year = gets.chomp
    print "発行月： "
    month = gets.chomp
    print "発行日： "
    date = gets.chomp

    if year == "" && month == "" && date == "" then
      # 発行日に関する入力がなかった場合、発行日にはnilを入力
      @search_term.publish_date = nil
    else
      year = year.to_i
      month = month.to_i
      date = date.to_i
      @search_term.publish_date = Date.new( year, month, date )
    end
  end

  # 検索のために入力した語句を確認する
  def confirm
    display_search_term = @search_term
    if @search_term.title == ""
      display_search_term.title = "指定しない"
    end
    if @search_term.author == ""
      display_search_term.author = "指定しない"
    end
    if @search_term.page == 0
      display_search_term.page = "指定しない"
    end
    if @search_term.publish_date == nil
      display_search_term.publish_date = "指定しない"
    end
    puts ""
    puts "**********************************"
    puts "以下の条件で検索します。"
    puts "書籍名： " + display_search_term.title.to_s
    puts "著者名： " + display_search_term.author.to_s
    puts "ページ数： " + display_search_term.page.to_s
    puts "発行日： " + display_search_term.publish_date.to_s
    puts ""
  end

  # 検索の実行を尋ねる
  def caution
    puts "検索を実行してもよろしいですか？　(yes/no)"
    while true
      @judge = gets.chomp.to_s
      case
        when @judge != "yes" && @judge != "no" then
          puts "yes または no を入力してください。"
        else
          break
      end
    end
  end

  # 蔵書データの検索
  def search
    @search_result = []
    @book_infos.each do |key, info|
      check_title = info.title.include?(@search_term.title)
      check_author = info.author.include?(@search_term.author)
      if info.page == @search_term.page then
        check_page = true
      end
      if info.publish_date == @search_term.publish_date then
        check_publish_date = true
      end
      if check_title == true || check_author == true || check_page == true || check_publish_date == true then
        @search_result << info
      end
    end
  end

  # 検索結果の表示
  def output
    if @search_result != [] then
      puts "\n------------------------------------------------------------------"
      @search_result.each { |info|
        print info.to_formatted_string
        puts "\n------------------------------------------------------------------"
      }
    else
      puts ""
      puts "------------------------------------------------------------------"
      puts "検索されませんでした。"
      puts "------------------------------------------------------------------"
    end
  end

  # 蔵書データを検索する際の一連の動作
  def search_book_info
    input
    confirm
    caution
    if @judge == "yes"
      search
      output
    end
  end

  # 蔵書データを全件ファイルへ書き込んで保存する
  def save_all_book_infos
    # csvファイルを書き込みモードで開く
    open(@csv_file_name, "w:UTF-8") {|file|
      @book_infos.each {|key, info|
        file.print(info.to_csv(key))
      } # 1行ずつの処理の終わり
      puts "\nファイルへ保存しました"
    }
  end

  # 処理の選択と選択後の処理を繰り返す
  def run
    while true
      # 機能選択画面を表示する
      print "
  1. 蔵書データの登録
  2. 蔵書データの表示
  3. 蔵書データの検索
  8. 蔵書データのファイルへの保存
  9. 終了

番号を選んでください (1, 2, 3, 8, 9): "

      # 文字の入力を待つ
      num = gets.chomp
      case
        when '1' == num
          # 蔵書データの登録
          add_book_info
        when '2' == num
          # 蔵書データの表示
          list_all_book_infos
        when '3' == num
          # 蔵書データの検索
          search_book_info
        when '8' == num
          # 蔵書データをファイルへ保存
          save_all_book_infos
        when '9' == num
          # アプリケーションの終了（このbreakはwhile文を中断させる）
          break
        else
          # 処理待ち画面に戻る
      end
    end
  end
end

# アプリケーションのインスタンスを作る
book_info_manager = BookInfoManager.new("book_info.csv")

# BookInfoManagerの蔵書データをセットアップする
book_info_manager.set_up

# BookInfoManagerの処理の選択と選択後の処理を繰り返す
book_info_manager.run