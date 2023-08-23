// SPDX-License-Identifier: UNLICENSED
pragma solidity >= 0.8.0;

import "./Fairlaunch.sol";
import "@openzeppelin/contracts/utils/Address.sol";
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract FairLaunchFactory {
  using Address for address payable;
  using SafeMath for uint256;

  address public feeTo;
  address _owner;
  uint256 public flatFee;
  uint256 public referral_fee;
  address public referral_address;
  uint256 public base_token_fee; // base token fee after finalize
  uint256 public sale_token_fee; // sale token fee after finalize        

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
  
  // Call this function before create(...)
  // Set base token and sale token fees 
  function setFees(
      uint256 _base_token_fee,
      uint256 _sale_token_fee
  ) public virtual {
      base_token_fee = _base_token_fee;
      sale_token_fee = _sale_token_fee;
  }

  function setFeeTo(address feeReceivingAddress) external onlyOwner {
    feeTo = feeReceivingAddress;
  }

  function setFlatFee(uint256 fee) external onlyOwner {
    flatFee = fee;
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

  function sendValue(address _token, address to, uint256 _selling_amount, uint256 _liquidityPercent) private {
    uint256 value = _selling_amount + _selling_amount.mul(_liquidityPercent).div(100);
    IBEP20(_token).transferFrom(msg.sender, to, value);
  }

  function getFeeTo() public view returns(address ) {
    return feeTo;
  }

  function getFlatFee() public view returns(uint256 ) {
    return flatFee;
  }

  function create(
    address _sale_token,
    address _base_token,
    bool presale_in_native,
    uint256 _buyback,
    bool _whitelist,
    uint256 _selling_amount,
    uint256 _softcap, 
    uint256 _liquidityPercent,
    uint256 _presale_start,
    uint256 _presale_end
  ) external payable enoughFee returns (address) {
    refundExcessiveFee();
    Fairlaunch newToken = new Fairlaunch(
      msg.sender,
      _sale_token,
      _base_token,
      presale_in_native,
      _buyback,
      _whitelist,
      _selling_amount,
      _softcap, 
      _liquidityPercent,
      _presale_start,
      _presale_end
    );

    sendValue(_sale_token, address(newToken), _selling_amount, _liquidityPercent);
    payable(feeTo).transfer(flatFee);
    return address(newToken);
  }
}