// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "./PresaleNew.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract PresaleFactoryNew {
  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  address _owner;
  uint256 public flatFee;
  uint256 public base_token_fee;
  uint256 public sale_token_fee;
  bool public presale_in_native;
  address public referralAddress;
  uint256 public referralFee;


  modifier enoughFee() {
    require(msg.value >= flatFee, "Flat fee");
    _;
  }

  modifier onlyOwner {
    require(msg.sender == _owner, "You are not owner");
    _;
  }

  constructor() {
    feeTo = msg.sender;
    flatFee = 10_000_000 gwei;
    _owner = msg.sender;
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

  function transferOwner(address to) public onlyOwner {
    _owner = to;
  }

  function refundExcessiveFee() internal {
    uint256 refund = msg.value.sub(flatFee);
    if (refund > 0) {
      payable(msg.sender).sendValue(refund);
    }
  }

  function sendValue(address _token, address to, uint256 _hardcap, uint256 _liquidity_rate, uint256 _liquidityPercent, uint256 _token_rate) private  {
    uint256 listing = _hardcap.mul(_liquidity_rate).mul(_liquidityPercent).div(100);
    uint256 value = _hardcap.mul(_token_rate).add(listing); 
    value = value.div(10 ** (18 - IBEP20(_token).decimals()));
    // value.div(10 ** 18);
    IBEP20(_token).transferFrom(msg.sender, to, value);
  }
  function create(
    address _sale_token,
    address _base_token, // Pool base token : BNB, BUSD, USDT, USDC, FLOKI
    uint256[2] memory _rates, // 0: token_rate, 1: liquidity_rate
    uint256[2] memory _raises, // 0: min, 1: max
    uint256 _softcap, 
    uint256 _hardcap,
    uint256 _liquidityPercent,
    uint256 _presale_start,
    uint256 _presale_end
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    PresaleNew newToken = new PresaleNew(
      msg.sender, 
      _sale_token, 
      _base_token, 
      _rates[0], _rates[1],
      _raises[0], _raises[1],
      _softcap, _hardcap, _liquidityPercent, 
      _presale_start, _presale_end
    );

    // const value = hardcap * presale * 1.02 + 0.98 * hardcap * listing * liquidity / 100
    // uint256 value = _selling_amount + _selling_amount.mul(_liquidityPercent).div(100);
    sendValue(_sale_token, address(newToken), _hardcap, _rates[1], _liquidityPercent, _rates[0]);
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}