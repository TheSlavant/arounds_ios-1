//
//  BaseChatViewController.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/29/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//
//import ALCameraViewController
import SVProgressHUD
import Firebase
import JSQMessagesViewController
import Presentr
import CropViewController


class BaseChatViewController: JSQMessagesViewController, UINavigationControllerDelegate {
    
    var navigationView: ARChatNavigationView = ARChatNavigationView.loadFromNib()
    lazy var acceptedView: ARChatAcceptedView = ARChatAcceptedView.loadFromNib()
    private(set) var viewModel: BaseChatViewModel!
    var myAvatar:Data?
    var otherAvatar:Data?
    var croppingParameters: CroppingParameters {
        
        return CroppingParameters(isEnabled: false, allowResizing: true, allowMoving: true, minimumSize: CGSize.init(width: 100, height: 100))
    }
    
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate func reloadData() {
        self.collectionView?.reloadData()
        
        if self.collectionView.contentSize.height - (self.collectionView.contentOffset.y + self.collectionView.frame.height) < 230 {
            self.scrollToBottom(animated: true)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.collectionView?.reloadData()
            if self.collectionView.contentSize.height - (self.collectionView.contentOffset.y + self.collectionView.frame.height) < 230 {
                self.scrollToBottom(animated: false)
            }
            
        }
        
        collectionView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(collectionTap(gesture:))))
        
    }
    
    fileprivate var playingAudioMessageView: MessageVoiceView? {
        didSet {
            oldValue?.stop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderId = ARUser.currentUser?.id ?? ""
        self.senderDisplayName = ""
        setupUI()
        viewModel.fetchAccept(completion: nil)
        viewModel.prepare()
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.init(width: 50, height: 50)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.init(width: 50, height: 50)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.setupHeaderView()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupHeaderView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.removeObservers()
        self.viewModel.loadNewMessages()
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    
    func setViewModel<T>(_ viewModel: T) where T: BaseChatViewModel {
        self.viewModel = viewModel
        self.viewModel.delegate = self
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @objc func collectionTap(gesture: UITapGestureRecognizer) {
        let a = self.inputToolbar.contentView as? ARChatInputContentView
        a?.textView.resignFirstResponder()
    }
    
    //MARK: - actions
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        self.viewModel.stopTyping()
        self.viewModel.sendMessage(with: text)
        
        self.inputToolbar.contentView.textView.text = nil
        chackAccpeted()
        updateSendButton()
    }
    
    
    func chackAccpeted() {
        setupAcceptedView()
        
        if let accepted = viewModel.accepted {
            if accepted.myAccept?.accept ?? .panding == .panding {
                setupAcceptedView()
            } else {
                acceptedView.close()
            }
        }
    }
    
}

extension BaseChatViewController: BaseChatViewModelDelegate {
    func didUpdateMessages(_ messages: [JSQMessage], in viewModel: BaseChatViewModel, hasNewMessage: Bool) {
        
        if messages.filter({$0.isIncomming}).count > 0 {
            if viewModel.accepted == nil {
                viewModel.fetchAccept {[weak self] (accepted) in
                    self?.chackAccpeted()
                }
            } else {
                chackAccpeted()
            }
            
        }
        
        
        collectionView.collectionViewLayout.sectionInset.bottom = messages.last?.isMediaMessage ?? false ? 60 : 30
        
        if hasNewMessage {
            reloadData()
        }
        
    }
    
    func didUpdateUsersThatAreTyping(_ users: Set<String>, in viewModel: BaseChatViewModel) {
        print(users)
    }
    
    func didUpdateChatAvailability(isChatActive: Bool) {
        
    }
    
    func didStartPreparingChat() {
        
    }
    
    func didEndPreparingChat() {
        
    }
    
    func didFetchedReciver(reciver: ARUser) {
        self.navigationView.titleLabel.text = "@" + (reciver.nickName ?? "")
        
        DispatchQueue.global().async { [weak self] in
            if let myURL = self?.viewModel.me?.getImageURL(), let otherURL = self?.viewModel.recever?.getImageURL() {
                do {
                    self?.myAvatar = try Data.init(contentsOf: myURL)
                    self?.otherAvatar = try Data.init(contentsOf: otherURL)
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                } catch { }
            }
        }
        
    }
}

// MARK: - Setup UI
extension BaseChatViewController {
    
    fileprivate func setupUI() {
        self.setupInputToolbar()
        self.setupCollectionView()
        self.setupAttachmentButton()
        self.setupSendButton()
        
        setupCollectionView()
        setupRefreshControl()
        view.setNeedsDisplay()
        view.setNeedsUpdateConstraints()
    }
    
    private func setupRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.collectionView.addSubview(self.refreshControl)
        self.refreshControl.addTarget(self, action: #selector(didLoadMoreMessagesTrigered(_:)), for: .valueChanged)
    }
    
    @objc fileprivate func didLoadMoreMessagesTrigered(_ sender: Any) {
        self.refreshControl.endRefreshing()
        self.viewModel.loadMoreMessages()
        self.playingAudioMessageView = nil
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        self.resignFirstResponder()
        openCameraSheet()
        updateSendButton()
        
    }
    
    func openCameraSheet() {
        let actionSheet = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let choose = UIAlertAction.init(title: NSLocalizedString("Выбрать фото", comment: ""), style: .default, handler: { [weak self] (action) in
            guard let weakSelf = self else {return}
            
            let libraryViewController = CameraViewController.imagePickerViewController(croppingParameters: weakSelf.croppingParameters) { [weak self] image, asset in
                guard let image = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return}
                self?.cropImage(image: image)
            }
            self?.present(libraryViewController, animated: true, completion: nil)
        })
        
        let takePhoto = UIAlertAction.init(title: NSLocalizedString("Снять фото", comment: ""), style: .default, handler: { [weak self] (action) in
            guard let weakSelf = self else {return}
            
            let cameraViewController = CameraViewController(croppingParameters: weakSelf.croppingParameters, allowsLibraryAccess: false) { [weak self] image, asset in
                
                guard let image = image else {
                    self?.dismiss(animated: true, completion: nil)
                    return}
                self?.cropImage(image: image)
            }
            
            self?.present(cameraViewController, animated: true, completion: nil)
        })
        
        
        let cancel = UIAlertAction.init(title: NSLocalizedString("Отмена", comment: ""), style: .cancel, handler: nil)
        
        actionSheet.addAction(choose)
        actionSheet.addAction(takePhoto)
        actionSheet.addAction(cancel)
        actionSheet.show()
        //        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func cropImage(image: UIImage) {
        let cropViewController = CropViewController(image: image)
        cropViewController.delegate = self
        self.dismiss(animated: true, completion: {
            DispatchQueue.main.async {
                self.present(cropViewController, animated: true)
            }
        })
    }
    
    fileprivate func updateSendButton() {
        let contentView = self.inputToolbar?.contentView
        let sendButton = contentView?.rightBarButtonItem
        
        var isTextToSend =  false
        if let textToSend = contentView?.textView.text, !textToSend.isEmpty {
            isTextToSend = true
        }
        
        sendButton?.isEnabled = isTextToSend && self.viewModel.isChatActive
        
        //        sendButton?.isEnabled = isButtonEnabled
        
        //        sendButton?.setImage(sendButtonImage, for: .normal)
    }
    
    func setupInputToolbar() {
        let height: CGFloat = 90
        self.inputToolbar.preferredDefaultHeight = height
        
        let contentView = self.inputToolbar.contentView as! ARChatInputContentView
        
        contentView.leftBarButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.rightBarButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.rightBarButtonContainerView.constraints.filter({$0.firstAttribute == NSLayoutConstraint.Attribute.height}).first?.constant = height - 14
        contentView.leftBarButtonContainerView.constraints.filter({$0.firstAttribute == NSLayoutConstraint.Attribute.height}).first?.constant = height - 14
        
        contentView.leftBarButtonContainerView.frame.size.height = height
        contentView.rightBarButtonContainerView.frame.size.height = height
        contentView.backgroundColor = UIColor.white
        contentView.textView.font = UIFont.init(name: "MontserratAlternates-Regular", size: 15)
        contentView.textView.textColor = .black
        contentView.textView.backgroundColor = UIColor.white
        contentView.textView.placeHolder = "Ваше сообщение"
        contentView.textView.placeHolderTextColor = UIColor.withHex("88889C")
        contentView.textView.layer.borderWidth = 0
        contentView.textView.layer.cornerRadius = 0
        contentView.textView.delegate = self
        contentView.inputView?.backgroundColor = UIColor.white
        collectionView.scrollRectToVisible(CGRect.init(x: 0, y: 100, width: 300, height: 300), animated: false)
    }
    
    private func setupAttachmentButton() {
        let contentView = self.inputToolbar.contentView as! ARChatInputContentView
        
        let attachmentButton = UIButton(type: .custom)
        attachmentButton.setImage(UIImage(named: "add_icon")?.resize(toWidth: 10), for: .normal)
        attachmentButton.frame = contentView.leftBarButtonContainerView.bounds
        attachmentButton.imageView?.contentMode = .scaleAspectFit
        attachmentButton.backgroundColor = UIColor.clear
        contentView.leftBarButtonItem = attachmentButton
        //        contentView.leftBarButtonItemWidth = 10
        //        contentView.leftContentPadding = 20
    }
    
    private func setupSendButton() {
        let contentView = self.inputToolbar.contentView as! ARChatInputContentView
        
        let sendButton = UIButton(type: .custom)
        sendButton.setImage(UIImage(named: "input_send"), for: .normal)
        sendButton.frame = contentView.rightBarButtonContainerView.bounds
        sendButton.imageView?.contentMode = .scaleAspectFit
        sendButton.backgroundColor = UIColor.clear
        contentView.rightBarButtonItem = sendButton
        updateSendButton()
    }
    
    private func setupHeaderView() {
        UIApplication.shared.keyWindow?.addSubview(navigationView)
        UIApplication.shared.keyWindow?.bringSubviewToFront(navigationView)
        
        let a = navigationView.frame.height + acceptedView.frame.height
        collectionView.collectionViewLayout.sectionInset.top = a
        collectionView.collectionViewLayout.sectionInset.bottom = viewModel.messages.last?.isMediaMessage ?? false ? 60 : 30
        
    }
    
    private func setupAcceptedView() {
        //        acceptedView = ARChatAcceptedView.loadFromNib()
        acceptedView.frame.origin.y = navigationView.frame.height
        self.view.addSubview(acceptedView)
        //        UIApplication.shared.keyWindow?.addSubview(acceptedView!)
        //        UIApplication.shared.keyWindow?.bringSubview(toFront: acceptedView!)
        
        let a = navigationView.frame.height + acceptedView.frame.height
        collectionView.collectionViewLayout.sectionInset.top = a
        collectionView.collectionViewLayout.sectionInset.bottom = viewModel.messages.last?.isMediaMessage ?? false ? 60 : 30
        
        acceptedView.didClickAccept = { [weak self] sender in
            self?.viewModel.accept()
            self?.chackAccpeted()
            
        }
        
        acceptedView.didClickDecline = { [weak self] sender in
            self?.declineSheet()
        }
        
    }
    
    func declineSheet() {
        // 1
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // 2
        
        let decline = UIAlertAction(title: "Отклонить", style: .default, handler: {[weak self] (action) in
            self?.viewModel.decline()
        })
        
        let block = UIAlertAction(title: "Заблокировать", style: .default, handler: { (action) in
            SVProgressHUD.show()
            Database.ProfileBlock.block(profile: self.viewModel.recever?.id ?? "", callback: { [weak self] (finish) in
                SVProgressHUD.dismiss()
                self?.viewModel.decline()
            })
        })
        
        //
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        // 4
        optionMenu.addAction(decline)
        optionMenu.addAction(block)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.present(optionMenu, animated: true, completion: nil)
        
    }
    
    
    private func setupCollectionView() {
        self.automaticallyScrollsToMostRecentMessage = true
        
        self.incomingCellIdentifier = MessageIncomingCell.cellReuseIdentifier()
        self.collectionView.register(MessageIncomingCell.nib(), forCellWithReuseIdentifier: self.incomingCellIdentifier)
        self.outgoingCellIdentifier = MessageOutgoingCell.cellReuseIdentifier()
        self.collectionView.register(MessageOutgoingCell.nib(), forCellWithReuseIdentifier: self.outgoingCellIdentifier)
        
        self.collectionView.collectionViewLayout = BaseChatViewFlowLayout()
        self.collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 50, height: 50)
        self.collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 50, height: 50)
        
        self.collectionView?.collectionViewLayout.messageBubbleFont = UIFont(name: "MontserratAlternates-Regular", size: 12)!
        
        self.collectionView.backgroundColor = UIColor.withHex("F7F9FC")
        collectionView.collectionViewLayout.minimumLineSpacing = 20
    }
    
}


// MARK: - Collection data source
extension BaseChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return self.viewModel.messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.viewModel.messages[indexPath.item]
        if message.senderId == self.senderId {
            return MessagesBubbleImage.outgoingBubbleImageView
        }
        
        return MessagesBubbleImage.incomingBubbleImageView
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = viewModel.messages[indexPath.row]
        var image: UIImage!
        if message.senderId == viewModel.me?.id {
            image = JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(data: myAvatar ?? Data()) ?? UIImage(), withDiameter: 100)
        } else {
            image = JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(data: otherAvatar ?? Data()) ?? UIImage(), withDiameter: 100)
        }
        return JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        
        let message = self.viewModel.messages[indexPath.row]
        guard let messageCell = cell as? JSQMessagesCollectionViewCell else {
            return cell
        }
        
        if let jsqMessageView = messageCell as? MessageCell {
            jsqMessageView.updateView(with: message)
        }
        
        if let cell = cell as? MessageIncomingCell {
            cell.reciver = viewModel.recever
        }
        return messageCell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let msg = viewModel.messages[indexPath.row]
        if msg.isMediaMessage {
            let vc = UIStoryboard.init(name: "ImageView", bundle: nil).instantiateViewController(withIdentifier: "ViewImageVC") as! ViewImageVC
            vc.imageView.kf.setImage(with: msg.attachmentURL)
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.viewModel.messages.count > indexPath.row {
            let message = self.viewModel.messages[indexPath.row]
            if message.type == .voice,
                let messageImageView = cell.contentView.subview(of: MessageVoiceView.self) {
                messageImageView.stop()
            }
        }
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        let message = viewModel.messages[indexPath.row]
        let text = message.text ?? ""
        
        if message.isMediaMessage {
            return CGSize(width: collectionView.frame.width, height: 170 + 80)
        }
        
        if message.type == .typing {
            return CGSize(width: collectionView.frame.width, height: 60 + 80)
        }
        
        let isIphone5 = UIScreen.main.bounds.height < 600
        
        let font = UIFont(name: "MontserratAlternates-Regular", size: isIphone5 == true ? 15 : 12)!
        let estimatedHeight = text.height(withConstrainedWidth: 244, font: font)
        
        return CGSize(width: collectionView.frame.width, height: estimatedHeight + CGFloat(100))
        
    }
    
    
    override func textViewDidChange(_ textView: UITextView) {
        updateSendButton()
        self.viewModel.enableUserTyping()
    }
    
}

//MARK: - AttachmentPopUpViewDelegate
extension BaseChatViewController: AttachmentPopUpViewDelegate {
    
    func didSelectItem(_ item: AttachmentPopUpItem, in attachmentPopUpView: AttachmentPopUpView) {
        
    }
    
}

extension BaseChatViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        
        if let image = image.resize(toWidth: 960) {
            self.viewModel.sendMessage(with: image)
        }
        cropViewController.dismiss(animated: true, completion: nil)
    }
}



