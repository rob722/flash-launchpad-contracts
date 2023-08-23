// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "../../tokens/BuybackBabyToken.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract BuybackBabyTokenFactory {
  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  address public _owner;
  uint256 public flatFee;

  modifier enoughFee() {
    require(msg.value >= flatFee, "Flat fee");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "Only Onwer Valid");
    _;
  }

  constructor() {
    feeTo = msg.sender;
    flatFee = 10_000_000 gwei;
    _owner = msg.sender;
  }
  
  function transferOwner(address to) public onlyOwner {
    _owner = to;
  }

  function setFeeTo(address feeReceivingAddress) external onlyOwner {
    feeTo = feeReceivingAddress;
  }

  function setFlatFee(uint256 fee) external onlyOwner {
    flatFee = fee;
  }

  function getFeeTo() public view returns(address ) {
    return feeTo;
  }

  function getFlatFee() public view returns(uint256 ) {
    return flatFee;
  }

  function refundExcessiveFee() internal {
    uint256 refund = msg.value.sub(flatFee);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function create(
    string memory name_,
    string memory symbol_,
    uint256 totalSupply_,
    address rewardToken_,
    address router_,
    uint256[5] memory feeSettings_
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    BuybackBabyToken newToken = new BuybackBabyToken(
      name_, symbol_, totalSupply_ * 10 ** 9, rewardToken_, router_,
      feeSettings_, msg.sender
    );
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}