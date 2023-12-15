//
//  SearchHistoryViewController.swift
//  PZXMapDemo
//
//  Created by 彭祖鑫 on 2023/12/15.
//

import UIKit

class SearchHistoryViewController: RootViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let stringArray = ["Adsdbhsbhcbd","Shicsaicaocoaicoasciosaosaosa","Dbaid","Cbsfbsifbsdfs","Nasjdsajdjadnjad","Axcbxhc njdiosisv jdijisojcoids cdisojcidos jcidosjojioddassdasdasddasdas"]
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setSubviews()

    }
    //MARK: – UI
    // subviews
    func setSubviews(){
        
        //左对齐
        collectionView.collectionViewLayout.perform(Selector.init(("_setRowAlignmentsOptions:")),with:NSDictionary.init(dictionary:["UIFlowLayoutCommonRowHorizontalAlignmentKey":NSNumber.init(value:NSTextAlignment.left.rawValue)]));
        
    }
    
    //MARK: – request
    // 获取服务数据
    
    
    //MARK: – 填充数据
    // 填充数据
    
    
    //MARK: – 点击事件
    
    
    //MARK: – Public Method
    // 公有方法
    
    
    //MARK: – Private Method
    // 私有方法

}


extension SearchHistoryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            
        return stringArray.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchHistoryCollectionViewCell", for: indexPath) as! SearchHistoryCollectionViewCell
        
        cell.titleLabel.text = stringArray[indexPath.row]
        
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellHeight = 26.0
         let cellMaxWidth = collectionView.bounds.width - 32 // 左右边距各 16 点
         let text = stringArray[indexPath.row]

         // 计算 Label 所需的大小
         let textBoundingRect = NSString(string: text).boundingRect(
             with: CGSize(width: cellMaxWidth, height: cellHeight),
             attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)], // 根据实际情况设置字体
             context: nil
         )

         // cell 的宽度取决于文字内容，但不超过最大宽度
         let cellWidth = min(textBoundingRect.width + 18, cellMaxWidth)
        print("cellWidth = \(cellWidth)")

         return CGSize(width: cellWidth, height: cellHeight)
     }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         // 设置 cell 之间的最小列间距为 8
         return 8
     }
    
    
    
    
    
    
    
    
}
