//
//  FestNewsViewController.swift
//  FestApp
//
//  Created by Oleg Grenrus on 30/10/14.
//  Copyright (c) 2014 Futurice Oy. All rights reserved.
//

import Foundation
import UIKit

class NewsTableCellView: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.postInit()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.postInit()
    }

    private func postInit() -> Void {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.clearColor()
        self.textLabel.textColor = UIColor.blackColor()
        self.textLabel.font = UIFont(name: "Palatino-Roman", size: 23)
    }

    override func setHighlighted(highlighted: Bool, animated: Bool) {
        self.textLabel.textColor = highlighted ? FEST_COLOR_GOLD : UIColor.blackColor()
    }
}

// WTF:
// http://stackoverflow.com/questions/25149604/are-view-controllers-with-nib-files-broken-in-ios-8-beta-5/25152545#25152545
class FestNewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    // This is a mirror of data managers' news signal
    // it's much easier to provide table view with stuff,
    // if we have it here
    private var news: Array<NewsItem> = []

    // https://developer.apple.com/library/ios/documentation/swift/conceptual/buildingcocoaapps/WritingSwiftClassesWithObjective-CBehavior.html
    @IBOutlet var tableView: UITableView! // <-- Implicitly Unwrapped Optionals

    override func viewDidLoad() {
        let newsSignal = FestDataManager.sharedFestDataManager().newsSignal
        newsSignal.subscribeNext { (news: AnyObject!) -> Void in
            // Have to do cast here, as ReactiveCocoa isn't as typed
            // as it would be good for swift!
            self.news = news as? Array<NewsItem> ?? []
            self.tableView.reloadData()
        }

        self.navigationItem.title = ""
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // http://stackoverflow.com/questions/24017316/pragma-mark-in-swift
    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let idx = indexPath.row

        let cellIdentfier = "NewsItemCell"
        let cell: NewsTableCellView = tableView.dequeueReusableCellWithIdentifier(cellIdentfier) as? NewsTableCellView ?? NewsTableCellView(style:UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentfier)


        let newsItem: NewsItem = news[idx]

        cell.textLabel.text = newsItem.title
        cell.detailTextLabel?.text = newsItem.published.description // TODO

        return cell
    }

    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return nil
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }

    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRectZero)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let newsItem = self.news[indexPath.row]

        FestDispatcher.sharedFestDispatcher().showNewsItem(newsItem)
    }
}
