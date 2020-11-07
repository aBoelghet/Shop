//
//  GSComplaintUpdatedTableCell.swift
//  Shopor
//
//  Created by Ratheesh on 17/12/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

protocol GSComplaintCellDelegate:class {
    func attachmentSelected(actionCell:GSComplaintsNestedComplaintActionTableCell)
    func replacementTitleSelected(selection:String)
    func replacementMessage(message:String, needToCloseComplaintCell:Bool)
    func imageButtonSelected(_ sender:UIButton, selectedImageView:UIImageView)
}

class GSComplaintUpdatedTableCell: UITableViewCell {
    
    @IBOutlet weak var complaints_tableView:UITableView!
    
    weak var delegate:GSComplaintCellDelegate?
    
    var complaintItem_array = [String]()
    var images_array = [UIImage]()
//    var selectedIndexPath:IndexPath?
    var feedBackMessage:String = ""
    var selectedString = ""
    
    var complaintCellIndex:Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addFewIntializers()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Configuring The Cell
    
    func configureTheCell(itemsToShow:[String]) {
        complaintItem_array = itemsToShow
        complaints_tableView.reloadData()
    }
    
    // MARK: - Setting up the initializers
    
    private func addFewIntializers() {
        
        complaints_tableView.dataSource = self
        complaints_tableView.delegate = self
        
         contentView.backgroundColor = UIColor(hexString: defaultTheme.verifyItems_complaintCell_BG)
    }
    
    // MARK: - Intializing With Data
    
    func intializeWith(feedback:String, selectedOption:String,imageArray:[UIImage]) {
        feedBackMessage = feedback
        images_array = imageArray
        selectedString = selectedOption
    }
}

// MARK: - Feedback textView Delegate Methods

extension GSComplaintUpdatedTableCell:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        delegate?.replacementMessage(message: textView.text, needToCloseComplaintCell: false)
        
        guard let actionCell = complaints_tableView.cellForRow(at: IndexPath(row: complaintItem_array.count, section: 0)) as? GSComplaintsNestedComplaintActionTableCell else {
            return
        }
        let message = textView.text ?? ""
        actionCell.charactersCount_lbl.text = "\(message.count)/\(GSConstant.verifyItemsFeedback_maxCharacter)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "" {
            return true
        }
        
        let currentText = textView.text ?? ""
        if (currentText.count + text.count) <= GSConstant.verifyItemsFeedback_maxCharacter {
            return true
        }
        return false
    }
}

// MARK: - Nested Table View Methods

extension GSComplaintUpdatedTableCell:UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complaintItem_array.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == complaintItem_array.count {
            guard let actionCell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.varifyOrderComplaintNestedActionTableCell) as? GSComplaintsNestedComplaintActionTableCell else {
                return UITableViewCell()
            }
            
            actionCell.attachment_btn.tag = indexPath.row
            actionCell.attachment_btn.addTarget(self, action: #selector(attachmentAction(_:)), for: .touchUpInside)
            actionCell.submit_btn.tag = indexPath.row
            actionCell.submit_btn.addTarget(self, action: #selector(submitAction(_:)), for: .touchUpInside)
            
            actionCell.feed_txtView.text = feedBackMessage
            actionCell.feed_txtView.delegate = self
            let message = actionCell.feed_txtView.text ?? ""
            actionCell.charactersCount_lbl.text = "\(message.count)/\(GSConstant.verifyItemsFeedback_maxCharacter)"
            complaintCellIndex = indexPath.row
            
            var index = 0
            for imageBtn in [actionCell.first_btn, actionCell.second_btn, actionCell.third_btn] {
                imageBtn?.addTarget(self, action: #selector(imageButtonSelected(_:)), for: .touchUpInside)
                imageBtn?.tag = index
                index += 1
            }
            
            let imageViewInstaces_array = [actionCell.first_imgView,actionCell.second_imgView,actionCell.third_imgView]
            
            for normalImgView in imageViewInstaces_array {
                normalImgView?.image = nil
            }
            
            for index in 0..<images_array.count {
                imageViewInstaces_array[index]?.image = images_array[index]
            }
            
            return actionCell
            
        } else {
            
            guard let normalLableCell = tableView.dequeueReusableCell(withIdentifier: GSString.CellIdentifier.verifyOrderComplaintNestedLableTableCell) as? GSComplaintNestedComplaintLableTableCell else {
                return UITableViewCell()
            }
            
//            normalLableCell.selection_imgView.image = #imageLiteral(resourceName: "Radio_off")
//            if let unwrappedIndexPathSection = selectedIndexPath {
//                if indexPath == unwrappedIndexPathSection {
//                    normalLableCell.selection_imgView.image = #imageLiteral(resourceName: "Radio_on")
//                }
//            }
//
            let optionString = complaintItem_array[indexPath.row]
            
            normalLableCell.selection_imgView.image = #imageLiteral(resourceName: "Radio_off")
            if optionString == selectedString {
                normalLableCell.selection_imgView.image = #imageLiteral(resourceName: "Radio_on")
            }
            
            normalLableCell.complaintTitle_lbl.text = complaintItem_array[indexPath.row]
            
            return normalLableCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == complaintItem_array.count {
            return UITableViewAutomaticDimension            // this will be 140
        } else {
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row != complaintItem_array.count {
            let optionString = complaintItem_array[indexPath.row]
            selectedString = optionString
            tableView.reloadData()
            delegate?.replacementTitleSelected(selection: selectedString)
        }
    }
    
    // MARK: - Cell Action Methods
    
    @objc private func attachmentAction(_ sender:UIButton) {
        
        guard let actionCell = complaints_tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? GSComplaintsNestedComplaintActionTableCell else {
            return
        }
        
        delegate?.attachmentSelected(actionCell: actionCell)
    }
    
    @objc private func submitAction(_ sender:UIButton) {
        guard let actionCell = complaints_tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? GSComplaintsNestedComplaintActionTableCell else {
            return
        }
        delegate?.replacementMessage(message: actionCell.feed_txtView.text, needToCloseComplaintCell: true)
    }
    
    @objc private func imageButtonSelected(_ sender:UIButton) {
        
        guard let indexForComplaintCell = complaintCellIndex else { return }
        guard let actionCell = complaints_tableView.cellForRow(at: IndexPath(row: indexForComplaintCell, section: 0)) as? GSComplaintsNestedComplaintActionTableCell else { return }
        
        delegate?.imageButtonSelected(sender, selectedImageView: [actionCell.first_imgView,actionCell.second_imgView,actionCell.third_imgView][sender.tag])
    }
}
