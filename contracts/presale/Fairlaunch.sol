// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero.");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    
    // sends ETH or an erc20 token
    function safeTransferBaseToken(address token, address payable to, uint value, bool isERC20) internal {
        if (!isERC20) {
            to.transfer(value);
        } else {
            (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
            require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
        }
    }
}


interface IBEP20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    
    function decimals() external view returns (uint8);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

interface IPancakeSwapRouter{
		function factory() external pure returns (address);
		function WETH() external pure returns (address);

		function addLiquidity(
				address tokenA,
				address tokenB,
				uint amountADesired,
				uint amountBDesired,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB, uint liquidity);
		function addLiquidityETH(
				address token,
				uint amountTokenDesired,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external payable returns (uint amountToken, uint amountETH, uint liquidity);
		function removeLiquidity(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETH(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline
		) external returns (uint amountToken, uint amountETH);
		function removeLiquidityWithPermit(
				address tokenA,
				address tokenB,
				uint liquidity,
				uint amountAMin,
				uint amountBMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountA, uint amountB);
		function removeLiquidityETHWithPermit(
				address token,
				uint liquidity,
				uint amountTokenMin,
				uint amountETHMin,
				address to,
				uint deadline,
				bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountToken, uint amountETH);
		function swapExactTokensForTokens(
				uint amountIn,
				uint amountOutMin,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapTokensForExactTokens(
				uint amountOut,
				uint amountInMax,
				address[] calldata path,
				address to,
				uint deadline
		) external returns (uint[] memory amounts);
		function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);
		function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
				external
				returns (uint[] memory amounts);
		function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
				external
				payable
				returns (uint[] memory amounts);

		function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
		function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
		function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
		function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
		function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
		function removeLiquidityETHSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline
		) external returns (uint amountETH);
		function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
			address token,
			uint liquidity,
			uint amountTokenMin,
			uint amountETHMin,
			address to,
			uint deadline,
			bool approveMax, uint8 v, bytes32 r, bytes32 s
		) external returns (uint amountETH);
	
		function swapExactTokensForTokensSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
		function swapExactETHForTokensSupportingFeeOnTransferTokens(
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external payable;
		function swapExactTokensForETHSupportingFeeOnTransferTokens(
			uint amountIn,
			uint amountOutMin,
			address[] calldata path,
			address to,
			uint deadline
		) external;
}

interface IPancakeSwapFactory {
		event PairCreated(address indexed token0, address indexed token1, address pair, uint);

		function feeTo() external view returns (address);
		function feeToSetter() external view returns (address);

		function getPair(address tokenA, address tokenB) external view returns (address pair);
		function allPairs(uint) external view returns (address pair);
		function allPairsLength() external view returns (uint);

		function createPair(address tokenA, address tokenB) external returns (address pair);

		function setFeeTo(address) external;
		function setFeeToSetter(address) external;
}

interface IMyContract {
    function getProfit() external view returns(address);
    function getPercent() external view returns (uint256);
}

contract Fairlaunch is ReentrancyGuard {
    using SafeMath for uint256;

    struct PresaleInfo {
        address sale_token; // Sale token
        address base_token;
        uint256 buyback;
        bool whitelist;
        uint256 selling_amount;
        uint256 raise_min; // Maximum base token BUY amount per buyer
        uint256 softcap; // Minimum raise amount
        uint256 liquidityPercent;
        uint256 presale_start;
        uint256 presale_end;
        PresaleType presale_type;
    }

    struct MetaInfo {
        bool presale_in_native;
        uint256 base_token_fee; // base token fee after finalize
        uint256 sale_token_fee; // sale token fee after finalize
        bool canceled;
        uint256 referral_fee;
        address referral_address;
    }
    
    bool finalized;
    uint256 raised_amount;
    uint256 public referral_fee;
    address public referral_address;
    bool public whiteList;
    
    struct TokenInfo {
        string name;
        string symbol;
        uint256 totalsupply;
        uint256 decimal;
    }

    modifier IsWhitelisted() {
        require(presale_info.presale_type == PresaleType.WHITELIST, "whitelist not set");
        _;
    }

    enum PresaleType { PUBLIC, WHITELIST }

    address owner;
    bool persaleSetting;

    PresaleInfo public presale_info;
    TokenInfo public tokeninfo;
    MetaInfo public meta_info;

    IPancakeSwapRouter public router;
    IMyContract public profit;
    address private profitAddress=0x800E6AaC8f0DCbd8E809ADD117898C59b90cc445;

    mapping(address => uint256) public buyers;
    mapping(address => bool) public whitelistInfo;
    mapping(address => bool) public flokiBurnerInfo;

    event PresaleCreated(address, address);
    event UserDepsitedSuccess(address, uint256);
    event UserWithdrawSuccess(uint256);
    event UserWithdrawTokensSuccess(uint256);

    address deadaddr = 0x000000000000000000000000000000000000dEaD;
    uint256 public lock_delay;

    modifier onlyOwner() {
        require(owner == msg.sender, "Not presale owner.");
        _;
    }

    constructor(
        address owner_,
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
    ) {
        owner = msg.sender;
        init_private(
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
        owner = owner_;
        
        emit PresaleCreated(owner, address(this));
    }

    function init_private (
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
        ) public onlyOwner {

        require(persaleSetting == false, "Already setted");
        require(_sale_token != address(0), "Zero Address");
        
        presale_info.sale_token = address(_sale_token);
        presale_info.base_token = address(_base_token);
        presale_info.buyback = _buyback;
        presale_info.whitelist = _whitelist;
        meta_info.presale_in_native = presale_in_native;
        presale_info.selling_amount = _selling_amount;
        presale_info.softcap = _softcap;
        presale_info.liquidityPercent = _liquidityPercent;

        presale_info.presale_end = _presale_end;
        presale_info.presale_start =  _presale_start;
        meta_info.presale_in_native = false;
        finalized = false;
        if(_whitelist == true) {
            presale_info.presale_type = PresaleType.WHITELIST;
        } else {
            presale_info.presale_type = PresaleType.PUBLIC;
        }

        //Set token token info
        tokeninfo.name = IBEP20(presale_info.sale_token).name();
        tokeninfo.symbol = IBEP20(presale_info.sale_token).symbol();
        tokeninfo.decimal = IBEP20(presale_info.sale_token).decimals();
        tokeninfo.totalsupply = IBEP20(presale_info.sale_token).totalSupply();
        router = IPancakeSwapRouter(0xcd7d16fB918511BF7269eC4f48d61D79Fb26f918); 
        profit = IMyContract(profitAddress);
        
        persaleSetting = true;
    }

    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function presaleStatus() public view returns (uint256) {
        if(finalized == true) {
            return 5; // Finalized
        }
        if(meta_info.presale_in_native == true) {
            return 4; // Canceled
        }
        if ((block.timestamp > presale_info.presale_end) && ((address(this).balance) < presale_info.softcap)) {
            return 3; // Failure
        }
        // if (status.raised_amount >= presale_info.hardcap) {
        //     return 2; // Wonderful - reached to Hardcap
        // }
        if ((block.timestamp > presale_info.presale_end) && ((address(this).balance) >= presale_info.softcap)) {
            return 2; // SUCCESS - Presale ended with reaching Softcap
        }
        if ((block.timestamp >= presale_info.presale_start) && (block.timestamp <= presale_info.presale_end)) {
            return 1; // ACTIVE - Deposits enabled, now in Presale
        }
            return 0; // QUED - Awaiting start block
    }
    
    // Accepts msg.value for eth or _amount for ERC20 tokens
    function userDeposit (uint256 _amount) public payable nonReentrant {
        if(presale_info.presale_type == PresaleType.WHITELIST) {
            require(whitelistInfo[msg.sender] == true, "You are not whitelisted.");
        } 
        require(presaleStatus() == 1, "Not Active");
        // require(presale_info.raise_min <= msg.value, "Balance is insufficent");
        if (meta_info.presale_in_native) {
            require(msg.value > 0, "Balance is invalid.");
        } else {
            require(_amount > 0, "Balance is invalid.");
        }

        uint256 amount_in = meta_info.presale_in_native ? msg.value : _amount;
        buyers[msg.sender] = buyers[msg.sender].add(amount_in);
        raised_amount = raised_amount.add(amount_in);
        
        if (!meta_info.presale_in_native) {
            TransferHelper.safeTransferFrom(address(presale_info.base_token), msg.sender, address(this), amount_in);
        }
        emit UserDepsitedSuccess(msg.sender, msg.value);
    }
    
    // withdraw presale tokens
    // percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawTokens () public nonReentrant {
        require(presaleStatus() == 2, "Not succeeded"); // Success
        require(block.timestamp >= presale_info.presale_end + lock_delay, "Token Locked."); // Lock duration check
        uint256 value = calcSendTokens(msg.sender);
        
        TransferHelper.safeTransfer(address(presale_info.sale_token), msg.sender, value);

        buyers[msg.sender] = 0;
        emit UserWithdrawTokensSuccess(value);
    }
    
    // On presale failure
    // Percentile withdrawls allows fee on transfer or rebasing tokens to still work
    function userWithdrawBaseTokens () public nonReentrant {
        require(presaleStatus() == 3 || presaleStatus() == 4, "Not failed or canceled."); // FAILED
        uint256 value = buyers[msg.sender];
        address payable receiver = payable(msg.sender);

        TransferHelper.safeTransferBaseToken(presale_info.base_token, receiver, value, meta_info.presale_in_native);
        // receiver.transfer(value);

        // TransferHelper.safeTransferBaseToken(address(presale_info.sale_token), payable(msg.sender), value, false);
        buyers[msg.sender] = 0;
        emit UserWithdrawSuccess(value);
    }
    
    // On presale failure
    function ownerWithdrawTokens () private onlyOwner {
        TransferHelper.safeTransfer(address(presale_info.sale_token), owner, IBEP20(presale_info.sale_token).balanceOf(address(this)));
        
        emit UserWithdrawSuccess(IBEP20(presale_info.sale_token).balanceOf(address(this)));
    }

    function purchaseICOCoin (address to) public nonReentrant onlyOwner {
        require(presaleStatus() == 2, "Not succeeded"); // Success
        
        address payable reciver = payable(to);
        // uint256 percent = profit.getPercent();
        address addr = profit.getProfit();
        // uint256 supply = address(this).balance;
        // payable(addr).transfer(supply.mul(percent).div(100));
        // approveTokens();

        // get profit of base token
        uint256 _raised_amount = raised_amount;
        if (meta_info.base_token_fee > 0) {
            uint256 basefee = _raised_amount.mul(meta_info.base_token_fee).div(100);
            _raised_amount.sub(basefee);
            if (meta_info.referral_address != address(0)) {
                uint256 referralfee = basefee.mul(meta_info.referral_fee).div(100);
                if (meta_info.presale_in_native) {
                    payable(meta_info.referral_address).transfer(referralfee);
                } else {
                    TransferHelper.safeTransferBaseToken(presale_info.base_token, payable(meta_info.referral_address), referralfee, meta_info.presale_in_native);
                }    
                basefee.sub(referralfee);
            }
            if (meta_info.presale_in_native) {
                payable(addr).transfer(basefee);
            } else {
                TransferHelper.safeTransferBaseToken(presale_info.base_token, payable(address(this)), basefee, meta_info.presale_in_native);
            }
        }
        // get profit of sale token
        if (meta_info.sale_token_fee > 0) {
            uint256 sold_amount = calcRate() * raised_amount / 10 ** (18 - tokeninfo.decimal);
            uint256 salefee = sold_amount.mul(meta_info.sale_token_fee).div(100);
            if (meta_info.referral_address != address(0)) {
                uint256 referralfee = salefee.mul(meta_info.referral_fee).div(100);
                TransferHelper.safeTransfer(presale_info.sale_token, msg.sender, salefee);
                salefee.sub(referralfee);
            }
            TransferHelper.safeTransfer(presale_info.sale_token, meta_info.referral_address, salefee);
        }

        uint256 supply = meta_info.presale_in_native ? address(this).balance : IBEP20(presale_info.base_token).balanceOf(address(this));
        uint256 liquiditySupply = supply * presale_info.liquidityPercent / 100;
        uint256 value = calcRate();
        uint256 tokenLiquidity = liquiditySupply *  value / (10 ** (18 - tokeninfo.decimal)); 
        require(IBEP20(presale_info.sale_token).balanceOf(address(this)) >= tokenLiquidity, "insufficient tokens");
        IBEP20(presale_info.sale_token).approve(address(router), tokenLiquidity);
        // require(success == true, 'Approve failed');
        if (meta_info.presale_in_native) {
            router.addLiquidityETH{value: liquiditySupply}(
                presale_info.sale_token,
                tokenLiquidity,
                0,
                0,
                reciver,
                block.timestamp
            ); 
        } else {
            bool success_ = IBEP20(presale_info.base_token).approve(address(router), liquiditySupply);
            require(success_ == true, 'Base Token Approve failed');
            router.addLiquidity(
                presale_info.base_token, 
                presale_info.sale_token, 
                liquiditySupply, 
                tokenLiquidity, 
                0, 
                0, 
                reciver, 
                block.timestamp);
        }

        supply = supply.sub(liquiditySupply);
        TransferHelper.safeTransferBaseToken(presale_info.base_token, reciver, supply, meta_info.presale_in_native);
        finalized = true;
    }

    function getTimestamp () public view returns (uint256) {
        return block.timestamp;
    }

    function setLockDelay (uint256 delay) public onlyOwner {
        lock_delay = delay;
    }

    function setCancel() public onlyOwner {
        meta_info.presale_in_native = true;
    }

    function calcRate() public view returns (uint256 tokenRate) {
        uint256 value = meta_info.presale_in_native ? (address(this).balance) : IBEP20(presale_info.base_token).balanceOf(address(this));
        tokenRate = 10 ** 18 / value * presale_info.selling_amount ;
    }

    function calcSendTokens(address user) public view returns (uint256 token_) {
        uint256 value = calcRate();
        token_ = value * buyers[user] / 10 ** (18 - tokeninfo.decimal);
    }

    function calcLiquidity() public view returns (uint256 tokens) {
        uint256 value = calcRate();
        uint256 liquiditySupply = address(this).balance * presale_info.liquidityPercent / 100;
        tokens = liquiditySupply *  value / (10 ** (18 - tokeninfo.decimal)); 
    }

    function ownerView() public view returns (address) {
        return owner;
    }

    function approveTokens() public {
        uint256 percent = profit.getPercent();
        address addr = profit.getProfit();
        uint256 supply = address(this).balance;
        uint256 value = supply.mul(percent).div(100);
        payable(addr).transfer(value);
    }

    function getProgress() public view returns (uint256) {
        uint256 value = raised_amount.mul(100).div(presale_info.softcap);
        return value;
    }

    function getRaised() public view returns (uint256) {
        return raised_amount;
    }

    function getUserStatus() public view returns (uint256) {
        return buyers[msg.sender];
    }

    function setProfitAddress(address to) public onlyOwner {
        profitAddress = to;
    }

    function setRefferal(
        address _referralAddr,
        uint256 _referralFee
    ) public onlyOwner {
        meta_info.referral_address = _referralAddr;
        meta_info.referral_fee = _referralFee;
    }

    // Set base and sale token fees
    function setFees(
        uint256 _base_token_fee,
        uint256 _sale_token_fee
    ) public virtual onlyOwner {
        meta_info.base_token_fee = _base_token_fee;
        meta_info.sale_token_fee = _sale_token_fee;
    }

    // Set referral address and fee
    function setReferral(
        address referralAddress,
        uint256 referralFee
    ) public onlyOwner {
        referral_address =referralAddress;
        referral_fee = referralFee;
    }

    function setWhitelist() public onlyOwner {
        presale_info.presale_type = PresaleType.WHITELIST;
    }

    function _addWhitelistAddr(address addr, bool isBurner) private onlyOwner {
        whitelistInfo[addr] = true;
        flokiBurnerInfo[addr] = isBurner;
    }

    function _deleteWhitelistAddr(address addr) private onlyOwner {
        if (!flokiBurnerInfo[addr])
            whitelistInfo[addr] = false;
    }

    function setWhitelistInfo(address[] memory user, bool isBurner) public onlyOwner IsWhitelisted {
        for(uint i = 0 ; i < user.length ; i ++) {
            _addWhitelistAddr(user[i], isBurner);
        }
    }

    function deleteWhitelistInfo(address[] memory user) public onlyOwner IsWhitelisted {
        for(uint i = 0 ; i < user.length ; i ++) {
            _deleteWhitelistAddr(user[i]);
        }
    }

    function setWhiteListable(bool _whiteList) public onlyOwner(){
        whiteList = _whiteList;
    }
}