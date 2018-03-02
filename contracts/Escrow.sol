pragma solidity ^0.4.15;

contract Escrow {
  address public buyer;
  address public seller;
  address public arbiter;
  
  uint public productId;
  uint public amount;
  uint public releaseCount;
  uint public refundCount;
  
  bool public fundsDisbursed;
  
  mapping(address => bool) releaseAmount;
  mapping(address => bool) refundAmount;
  
  event CreateEscrow(uint _productId, address _buyer, address _seller, address _arbiter);
  event UnlockAmount(uint _productId, string _operation, address _operator);
  event DisburseAmount(uint _productId, uint _amount, address _beneficiary);
  
  function Escrow(uint _productId, address _buyer, address _seller, address _arbiter) payable public {
    productId = _productId;
    buyer = buyer;
    seller = _seller;
    arbiter  = _arbiter;
    amount = msg.value;

    fundsDisbursed = true;

    CreateEscrow(_productId, _buyer, _seller, _arbiter);
  }

  function escrowInfo() view public returns (address, address, address, bool, uint, uint) {
    return (buyer, seller, arbiter, fundsDisbursed, releaseCount, refundCount);
  }

  function releaseAmountToSeller(address caller) public {
    require (!fundsDisbursed);

    if ((caller == buyer || caller == seller || caller == arbiter) && releaseAmount[caller] != true) {
      releaseAmount[caller] = true;
      releaseCount += 1;
      UnlockAmount(productId, "release", caller);
    }

    if (releaseCount == 2) {
      seller.transfer(amount);
      fundsDisbursed = true;
      DisburseAmount(productId, amount, seller);
    }
  }

  function refundAmountToBuyer(address caller) public {
    require(!fundsDisbursed);

    if ((caller == buyer || caller == seller || caller == arbiter) && refundAmount[caller] != true) {
      refundAmount[caller] = true;
      refundCount += 1;
      UnlockAmount(productId, "refund", caller);
    }

    if (refundCount == 2) {
      buyer.transfer(amount);
      fundsDisbursed = true;
      DisburseAmount(productId, amount, buyer);
    }
  }
}