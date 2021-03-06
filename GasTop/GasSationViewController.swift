//
//  GasSationViewController.swift
//  GasTop
//
//  Created by Alumno on 11/11/18.
//  Copyright © 2018 Gekko. All rights reserved.
//

import UIKit

class GasSationViewController: UIViewController {

    var sceneMode: ESceneMode = .NA;
    var gasStationId: Int?;
    private var gasStation: GasStation?;
    private var stationReviews: [Review] = [];

    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var magnaPriceText: UITextField!
    @IBOutlet weak var premiumPriceText: UITextField!
    @IBOutlet weak var dieselPriceText: UITextField!
    
    @IBOutlet weak var generalScore: RatingControl!
    @IBOutlet weak var gasScore: RatingControl!
    @IBOutlet weak var servicesScore: RatingControl!
    @IBOutlet weak var timeScore: RatingControl!
    
    
    @IBOutlet weak var reviewsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(GasSationViewController.didTapReviews))
        reviewsLabel.addGestureRecognizer(tapRecognizer)

    }
    
    @objc private func didTapReviews() {
        performSegue(withIdentifier: "toStationReviews", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GasStation.getStation(withId: gasStationId!, callback: { (stations:[GasStation]) in
            
            if (stations.count > 0) {
                self.gasStation = stations[0];
                self.navigationItem.title = self.gasStation!.name;
                
                Review.getReviews(forGasStationId: self.gasStationId!, callback: { (reviews:[Review]) in
                    self.stationReviews = reviews;
                    self.gasStation!.computeGasStationScoring(fromReviews: reviews)
                    self.assignValuesToOutlets();
                    //reviewsVC.reviews = reviews;

                })
            }
            else {
                print("Station \(self.gasStationId!) could not load station object");
            }
        })
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if let targetVC = segue.destination as? ReviewViewController {
            
            targetVC.byUserId = User.getLoggedUserId();
            targetVC.forStationId = gasStationId;
            
            targetVC.sceneMode = .Create;
        }
        else if let targetVC = segue.destination as? ReviewTableViewController {
            targetVC.reviews = stationReviews;
        }
    }
    
    private func assignValuesToOutlets() {
        distanceLabel.text = "768m"
        addressLabel.text = gasStation!.address;
        
        magnaPriceText.text = String(gasStation!.getAvgMagnaPrice());
        premiumPriceText.text = String(gasStation!.getAvgPremiumPrice());
        dieselPriceText.text = String(gasStation!.getAvgDieselPrice());
        magnaPriceText.isUserInteractionEnabled = false;
        premiumPriceText.isUserInteractionEnabled = false;
        dieselPriceText.isUserInteractionEnabled = false;
        
        generalScore.rating = Double(gasStation!.getAvgGeneralScore());
        gasScore.rating = Double(gasStation!.getAvgGasScore());
        servicesScore.rating = Double(gasStation!.getAvgServiceScore());
        timeScore.rating = Double(gasStation!.getAvgTimeScore());
        generalScore.editable = false;
        gasScore.editable = false;
        servicesScore.editable = false;
        timeScore.editable = false;
    }
}

enum ESceneMode {
    case Create;
    case View;
    case Update;
    case NA;
}
