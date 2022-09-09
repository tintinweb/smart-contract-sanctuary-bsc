/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract USDTPair is Ownable {
    address public coinbs = address(0x55d398326f99059fF775485246999027B3197955); // dot 18
    uint256 public burnbs; // dot 4, burn 14% = 1400
    address public addrFeeBuy = address(0xec4d7b54444Fe6EB714a0F4e95Eb5f8ca4694b49);
    address public addrFeeSell = address(0xDACeD7b49A357edEbcd6483d095DE297046e9510);
    uint256 public allfee;
    uint256 public curfee = 30; // dot 4

    address public seeadd = address(0xf48707107879eAD0169FC94689c13d1828CFB5eE);

    uint256 public limitsec = 30;
    uint256 public limitnum =  10000 * 10 ** 18;

    // coin => price(dot 18), step(dot 18), initprice(dot 18), dot, stime, burn(dot 4), usdt
    mapping(address => uint256[7]) _n;
    mapping(address => bool) _r;

    constructor(address role) {
        _r[role] = true;
    }

    event Swap(address indexed a1, address indexed a2, uint256 amount, uint256 p1, uint256 p2);

    function setBaseAddr(address base, address see) public onlyOwner {
        coinbs = base;
        seeadd = see;
    }

    function setFeeAddr(address addrBuy, address addrSell) public onlyOwner {
        addrFeeBuy = addrBuy;
        addrFeeSell = addrSell;
    }

    function setBuyLimit(uint256 sec, uint256 num) public onlyOwner {
        limitsec = sec;
        limitnum = num;
    }

    function setCurFee(uint256 curf) public onlyOwner {
        curfee = curf;
    }

    function setBurnbs(uint256 b) public onlyOwner {
        require(b <= 10000);
        burnbs = b;
    }

    function setRole(address addr, bool state) public onlyOwner {
        _r[addr] = state;
    }

    function getRole(address addr) public view returns(bool) {
        return _r[addr];
    }

    function addPair(address addr, uint256[7] memory nums) public {
        require(_r[_msgSender()] || owner() == _msgSender());
        _n[addr] = nums;
    }

    function setPairBurn(address addr, uint256 b) public onlyOwner {
        require(b <= 10000);
        _n[addr][5] = b;
    }

    function addLiquidity(address con, uint256 amount) public onlyOwner {
        IERC20(con).transferFrom(_msgSender(), address(this), amount);
    }

    function getPair(address addr) public view returns
    (uint256[7] memory, uint256[7] memory, address) {
        uint256[7] memory assets = [
        IERC20(addr).balanceOf(_msgSender()),
        IERC20(addr).allowance(_msgSender(), address(this)),
        IERC20(coinbs).balanceOf(_msgSender()),
        IERC20(coinbs).allowance(_msgSender(), address(this)),
        IERC20(seeadd).balanceOf(_msgSender()),
        IERC20(seeadd).allowance(_msgSender(), address(this)),
        IERC20(addr).balanceOf(address(this))];
        return (_n[addr], assets, seeadd);
    }

    function swap(address a1, address a2, uint256 coinNum) public payable {
        if (a1 == coinbs) {
            require(_n[a2][4] < block.timestamp && _n[a2][0] > 0);

            if (_n[a2][4] + limitsec > block.timestamp) {
                require(coinNum <= limitnum);
            }

            // buy basecoin -> coin   basecoin = usdt | see
            IERC20(coinbs).transferFrom(_msgSender(), address(this), coinNum);

            uint256 baseNum = coinNum * (10000 - burnbs) / 10000;
            uint256 baseNum_Feed = subFee(baseNum);

            coinNum = getGen1Y2C(_n[a2][0], _n[a2][1], baseNum_Feed, _n[a2][3]);
            uint256 pStep = getStep(a2, coinNum);
            uint256 pre_price = _n[a2][0];
            _n[a2][0] += pStep;

            _n[a2][6] += baseNum_Feed;

            IERC20(a2).transfer(_msgSender(), coinNum);
            emit Swap(a1, a2, baseNum, pre_price, _n[a2][0]);

            sendBuyFee();
        } else if (a2 == coinbs) {
            require(_n[a1][4] < block.timestamp && _n[a1][0] > 0);
            // sell coin -> basecoin
            IERC20(a1).transferFrom(_msgSender(), address(this), coinNum);

            coinNum = coinNum * (10000 - _n[a1][5]) / 10000;
            (uint256 baseNum,uint256  pStep) = getBaseNumAndStep(a1, coinNum, 1);
            uint256 pre_price = _n[a1][0];
            _n[a1][0] -= pStep;
            require(_n[a1][0] >= _n[a1][2]);
            uint256 afterfee = subFee(baseNum);

            require(_n[a1][6] > afterfee);
            _n[a1][6] -= afterfee;

            IERC20(coinbs).transfer(_msgSender(), afterfee);
            emit Swap(a1, a2, baseNum, pre_price, _n[a1][0]);
            sendSellFee();
        }
    }

    function subFee(uint256 all) private returns(uint256) {
        uint256 cfee = all * curfee / 10000;
        allfee += cfee;
        return all - cfee;
    }

    function sendBuyFee() private {
        IERC20(coinbs).transfer(addrFeeBuy, allfee);
        allfee = 0;
    }

    function sendSellFee() private {
        IERC20(coinbs).transfer(addrFeeSell, allfee);
        allfee = 0;
    }

    receive() external payable {}

    // coin addr & coin num & kind = 0 = buy, kind = 1 = sell
    function getBaseNumAndStep(address addr, uint256 coins, uint256 kind)
    public view returns(uint256, uint256) {
        uint256 pStep = getStep(addr, coins);
        uint256 pAvg;
        if (kind == 1) {pAvg = _n[addr][0] - (pStep  / 2);
        } else {pAvg = _n[addr][0] + (pStep  / 2);}
        uint256 amount = coins * pAvg / 10 ** _n[addr][3];
        return (amount, pStep);
    }

    function getStep(address addr, uint256 coins) public view returns(uint256) {
        return coins * _n[addr][1] / 10 ** _n[addr][3];
    }

    function getGen1Y2C(uint256 p, uint256 f, uint256 u, uint256 dot)
    public pure returns(uint256) {
        uint256 gen2 = getGen2(4 * (p**2) + 8 * f * u);
        if (gen2 <= 2 * p) { return 0; }
        return (gen2 - 2 * p) * (10 ** dot) / (2 * f);
    }

    function getGen2(uint256 x) public pure returns(uint256) {
        uint256 z = (x+1)/2; uint256 y = x;
        while(z < y) {y = z; z = (x/z+z)/2;}
        return y;
    }

}