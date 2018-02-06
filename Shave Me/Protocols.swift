//
//  Protocols.swift
//  Shave Me
//
//  Created by NoorAli on 12/15/16.
//  Copyright © 2016 NoorAli. All rights reserved.
//

import UIKit

// protocol used for sending data back
protocol ViewControllerInterationProtocol: class {
    func onViewControllerInteractionListener(interactionType: VCInterationType, data: Any?, childVC: UIViewController?)
}

// protocol used for table view cells taps inside the cell
protocol TableViewCellProtocol: class {
    func didClickOnCell(indexPath: IndexPath, cell: UITableViewCell, data: Any?, sender: Any)
}

enum VCInterationType {
    case userRegistered
    case userLogin
    case barberLogin
    case addReview
    case selectServices
    case selectFacilities
    case selectReportStatus
    case selectStylist
    case reservationConfirmed
    case appointmentCancelled
    case openAppointmentDetailVC
}
