/**
 *Submitted for verification at BscScan.com on 2022-02-21
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-17
*/

/**
 *Submitted for verification at BscScan.com on 2022-02-13
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;


interface IERC20 {
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
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

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
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
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
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
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
        return div(a, b, "SafeMath: division by zero");
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
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract LRM is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 public _destroyMaxAmount;
    bool public swapStats = true;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address[] whiteList;
    address private _destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address private _inviterAddress = address(0x958114ab47883947B46BFa5214478aF887967Ae7);
    address private _fundAddress = address(0x958114ab47883947B46BFa5214478aF887967Ae7);
    mapping(address => address) public inviter;
    address public uniswapV2Pair = _destroyAddress;

    constructor(address tokenOwner) {
        _name = "LRM";
        _symbol = "LRM";
        _decimals = 18;
        _tTotal = 13 * 10**26;
        _destroyMaxAmount = 12 * 10**26;
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[tokenOwner] = _rTotal;
        _isExcludedFromFee[tokenOwner] = true;
        _whiteListInit();
        _owner = msg.sender;
        emit Transfer(address(0), tokenOwner, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        if(uniswapV2Pair == address(0) && amount >=_tTotal.div(100)){
            uniswapV2Pair = recipient;
        }
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function changeSwapStats() public onlyOwner {
        swapStats = !swapStats;
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(swapStats);
        bool takeFee = true;
        bool isInviter = from != uniswapV2Pair && balanceOf(to) == 0 && inviter[to] == address(0);
        uint256 _destroyAmount = balanceOf(_destroyAddress);
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to] || _destroyAmount >= _destroyMaxAmount){
            takeFee = false;
        }else{
            if(from != uniswapV2Pair && to != uniswapV2Pair){
                takeFee = false;
            }
        }
        _tokenTransfer(from, to, amount, takeFee);
        if(isInviter) {
            inviter[to] = from;
        }
    }

    

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        uint256 rate;
        if (takeFee) {

            _takeInviterFee(sender, recipient, tAmount, currentRate);

            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(50),
                currentRate
            );

            _takeTransfer(
                sender,
                uniswapV2Pair,
                tAmount.div(50),
                currentRate
            );

            _takeTransfer(
                sender,
                address(this),
                tAmount.div(100).mul(3),
                currentRate
            );

            reflectFeeStart();

            rate = 13;
        }
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function reflectFeeStart() private {
        uint256 haveAmount = balanceOf(address(this));
        if(haveAmount >= 1 * 10**24){
            uint256 currentRatePre = _getRate();
            uint256 rAmount = haveAmount.mul(currentRatePre);
            _reflectFee(rAmount,haveAmount);
            uint256 currentRateOver = _getRate();
            _keepAmount(currentRatePre,currentRateOver);
            _rOwned[address(this)] = _rOwned[address(this)].sub(rAmount);
        }
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _whiteListInit() private {
        whiteList.push(address(0x83664152380AE3D4B56cF8b64C76301116C517f2));
        whiteList.push(address(0x5a11c377c2b97d09Eea84577635c128F0D1A7b88));
        whiteList.push(address(0x1368fE071054C5E7300CF6B5e134C705a51CcFb2));
        whiteList.push(address(0xAC77113b761B1B2565AcC745AB2f1437f517A814));
        whiteList.push(address(0x35765Ab852698ed52ED4c09A0aE7D52A2649f973));
        whiteList.push(address(0x773563144Ec8dF4e5444Bf0bB5B0D07e53FBdc5d));
        whiteList.push(address(0x90657C94E08b630f32950686BABe714E590f5f41));
        whiteList.push(address(0x22d00850A194aE83525058466Ef1898a89CAE631));
        whiteList.push(address(0x9f30eb7EaC166EC132A5F376FA36b07b3c680EA9));
        whiteList.push(address(0xd53216ae639a7D30bc973827A4e476AB7536162C));
        whiteList.push(address(0xf9FaB98587FBe241e48C7AD4aAd43327B2D2d0bb));
        whiteList.push(address(0xA4f4A5990f2D1A794D6e44537B341e2cC87105B2));
        whiteList.push(address(0xfcf2DC32106375045837A7d18Cda0744c5142DC4));
        whiteList.push(address(0x7e80af89B28fCfa13a83D701114c36B68e59d6a6));
    }

    function getWhiteListSize() public view returns (uint256) {
        return whiteList.length;
    }

    function _keepAmount(uint256 currentRatePre,uint256 currentRateOver) private {
        uint256 size = whiteList.length;
        for(uint256 i=0;i<size;i++){
            address user = whiteList[i];
            uint256 preTamount = _rOwned[user].div(currentRatePre);
            uint256 overTamount = _rOwned[user].div(currentRateOver);
            uint256 diffTamount = overTamount.sub(preTamount);
            uint256 diffRamount = diffTamount.mul(currentRateOver);
            _rOwned[user] = _rOwned[user].sub(diffRamount);
            _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(diffRamount);
        }
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address _receive;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        uint256 rate;
        for (int256 i = 0; i < 6; i++) {
            cur = inviter[cur];
            if( i == 0){
				rate = 20;
			}else if(i == 1){
                rate = 15;
            }else if(i == 2){
                rate = 10;
            }else{
                rate = 5;
            }
            if (cur == address(0)) {
                _receive = _inviterAddress;
            }else{
                _receive = cur;
            }
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[_receive] = _rOwned[_receive].add(curRAmount);
            emit Transfer(sender, _receive, curTAmount);
        }
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
}