//
//  ShopCatCollectionLayout.swift
//  PickZyShoppingApp
//
//  Created by Ratheesh TR on 4/7/18.
//  Copyright © 2018 PickZy Software Pvt Ltd. All rights reserved.
//

import UIKit

class ShopCatCollectionLayout: UICollectionViewFlowLayout {
    
    override var collectionViewContentSize : CGSize {
        // Only support single section for now.
        // Only support Horizontal scroll
        
        assignTheCellSize()
        
        let count = self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: 0)
        
        let tempFrame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.size.width, height: self.collectionView!.frame.size.height)

//        let canvasSize = self.collectionView!.frame.size
        
        let canvasSize = tempFrame.size
        
        var contentSize = canvasSize
        if self.scrollDirection == UICollectionViewScrollDirection.horizontal {
            let rowCount = Int((canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1)
            let columnCount = Int((canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1)
            let page = ceilf(Float(count!) / Float(rowCount * columnCount))
            contentSize.width = CGFloat(page) * canvasSize.width
            contentSize.height = 0
        }
        return contentSize
    }
    
    func frameForItemAtIndexPath(_ indexPath: IndexPath) -> CGRect {
        
        assignTheCellSize()
        
        let tempFrame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.size.width, height: self.collectionView!.frame.size.height)
        
        //        let canvasSize = self.collectionView!.frame.size
        
        let canvasSize = tempFrame.size
        
        let rowCount = Int((canvasSize.height - self.itemSize.height) / (self.itemSize.height + self.minimumInteritemSpacing) + 1)
        let columnCount = Int((canvasSize.width - self.itemSize.width) / (self.itemSize.width + self.minimumLineSpacing) + 1)
        
        let pageMarginX = (canvasSize.width - CGFloat(columnCount) * self.itemSize.width - (columnCount > 1 ? CGFloat(columnCount - 1) * self.minimumLineSpacing : 0)) / 2.0
//        let pageMarginY = (canvasSize.height - CGFloat(rowCount) * self.itemSize.height - (rowCount > 1 ? CGFloat(rowCount - 1) * self.minimumInteritemSpacing : 0)) / 2.0
        let pageMarginY = CGFloat(0)
        let page = Int(CGFloat(indexPath.row) / CGFloat(rowCount * columnCount))
        let remainder = Int(CGFloat(indexPath.row) - CGFloat(page) * CGFloat(rowCount * columnCount))
        let row = Int(CGFloat(remainder) / CGFloat(columnCount))
        let column = Int(CGFloat(remainder) - CGFloat(row) * CGFloat(columnCount))
        
        var cellFrame = CGRect.zero
        cellFrame.origin.x = pageMarginX + CGFloat(column) * (self.itemSize.width + self.minimumLineSpacing)
        cellFrame.origin.y = pageMarginY + CGFloat(row) * (self.itemSize.height + self.minimumInteritemSpacing)
        cellFrame.size.width = self.itemSize.width
        cellFrame.size.height = self.itemSize.height
        
        if self.scrollDirection == UICollectionViewScrollDirection.horizontal {
            cellFrame.origin.x += CGFloat(page) * canvasSize.width
        }
        
        return cellFrame
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attr = super.layoutAttributesForItem(at: indexPath)?.copy() as! UICollectionViewLayoutAttributes?
        attr!.frame = self.frameForItemAtIndexPath(indexPath)
        return attr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let originAttrs = super.layoutAttributesForElements(in: rect)
        var attrs: [UICollectionViewLayoutAttributes]? = Array<UICollectionViewLayoutAttributes>()
        
        for attr in originAttrs! {
            let idxPath = attr.indexPath
            let itemFrame = self.frameForItemAtIndexPath(idxPath)
            if itemFrame.intersects(rect) {
                let nAttr = self.layoutAttributesForItem(at: idxPath)
                attrs?.append(nAttr!)
            }
        }
        
        return attrs
    }
    
    func assignTheCellSize() {
        
        let reqFrame = self.collectionView!.frame
        
//        let reqFrame = CGRect(x: self.collectionView!.frame.origin.x, y: self.collectionView!.frame.origin.y, width: self.collectionView!.frame.size.width, height: self.collectionView!.frame.size.height)
        
        
        var cellWidth = CGFloat()
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            cellWidth = (reqFrame.size.width - 40) / 3.0
        } else {
            cellWidth = (reqFrame.size.width - 60) / 7.0
            
            var  remainder = Int((self.collectionView?.frame.size.width)!.truncatingRemainder(dividingBy: cellWidth))
            while remainder > 5 {
                
                cellWidth = cellWidth - 1
                remainder = Int((self.collectionView?.frame.size.width)!.truncatingRemainder(dividingBy: cellWidth+minimumInteritemSpacing))
            }
        }
        
        
//        cellWidth = (reqFrame.size.width - 40) / 3.0
        
//        let cellHeight = (reqFrame.size.height - 10) / 2.0
        
        let cellHeight = cellWidth + 30             // 30 is for shop catgory name label
        let cellSize = CGSize(width: cellWidth , height: cellHeight)
        
        self.itemSize = cellSize
        
    }
}
