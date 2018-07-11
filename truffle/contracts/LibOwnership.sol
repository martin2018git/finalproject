pragma solidity ^0.4.21;


library LibOnwership {


  struct OwnerRecord {
  /* properties relevant to ownership */
    bool isActive;         // is this record active (if not it will be wiped out after a while)
    address holder;        // address of the current owner
    string holderContact;  // email address for notifications
    uint unclaimedEther;   // unclaimed amounts

 /* properties used during the purchase process */
    uint bidAmount;        // amount the bidder submitf for purchase
    uint ownershipPoints;  // current share

 /* properties used during the sale process */
    uint proceeds;         // amount to be returned from the sale price

 /* properties used during the ownership transfer */
    uint lockedOwnershipPoints;

  }// OwnerRecord






}//LibOwnership
