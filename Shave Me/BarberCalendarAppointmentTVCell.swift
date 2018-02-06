//
//  BarberCalendarAppointmentTVCell.swift
//  Shave Me
//
//  Created by NoorAli on 1/31/17.
//  Copyright © 2017 NoorAli. All rights reserved.
//

import UIKit

class BarberCalendarAppointmentTVCell: UITableViewCell {

    @IBOutlet weak var startTimeLabel : UILabel!
    @IBOutlet weak var endTimeLabel : UILabel!
    @IBOutlet weak var verticalLineView : UIView!
    @IBOutlet weak var stylistNameLabel : UILabel!
    @IBOutlet weak var descriptionLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func setStatus(statusId: Int?) {
        guard let statusId = statusId else {
            return
        }
        
        let statusColor: UIColor
        switch statusId {
        case AppoinmentModel.APPOINMENT_CANCELLED_BY_SHOP:
            statusColor = UIColor.COLfd8080()
            break
        case AppoinmentModel.APPOINMENT_PENDING:
            statusColor = UIColor.COL47d9bf()
            break
        case AppoinmentModel.APPOINMENT_CONFIRMED:
            statusColor = UIColor.COLffa800()
            break
        case AppoinmentModel.APPOINMENT_CANCELLED_BY_USER, AppoinmentModel.APPOINMENT_CANCELLATION_APPROVED:
            statusColor = UIColor.COLfd8080()
            break
        case AppoinmentModel.APPOINMENT_CONFIRMED_NOT_ATTEND:
            statusColor = UIColor.COLfd8080()
            break
        case AppoinmentModel.APPOINMENT_COMPLETED:
            statusColor = UIColor.COLffa800()
            break
        case AppoinmentModel.APPOINMENT_AUTO_CANCELLED:
            statusColor = UIColor.COLfd8080()
            break
        default:
            statusColor = UIColor.black
            break
        }
        
        self.verticalLineView.backgroundColor = statusColor
    }
}
