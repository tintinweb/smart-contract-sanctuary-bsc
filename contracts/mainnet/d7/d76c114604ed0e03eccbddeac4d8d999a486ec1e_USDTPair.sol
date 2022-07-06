/**
 *Submitted for verification at BscScan.com on 2022-07-06
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-14
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

contract USDTPair {
    address public coinbs = address(0x55d398326f99059fF775485246999027B3197955); // dot 18
    uint256 public burnbs; // dot 4, burn 14% = 1400
    address public addrFeeBuy = address(0xec4d7b54444Fe6EB714a0F4e95Eb5f8ca4694b49);
    address public addrFeeSell = address(0xDACeD7b49A357edEbcd6483d095DE297046e9510);
    uint256 public allfee;
    uint256 public curfee = 50; // dot 4

    address public seeadd = address(0xf48707107879eAD0169FC94689c13d1828CFB5eE);

    uint256 public limitsec = 30;
    uint256 public limitnum =  10000 * 10 ** 18;

    // coin => price(dot 18), step(dot 18), initprice(dot 18), dot, stime, burn(dot 4), usdt
    mapping(address => uint256[7]) _n;
    mapping(address => bool) _r;

    constructor() {
        _r[_msgSender()] = true;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    event Swap(address indexed a1, address indexed a2, uint256 amount, uint256 p1, uint256 p2);

    function setBaseAddr(address base, address see) public {
        require(_r[_msgSender()]);
        coinbs = base;
        seeadd = see;
    }

    function setFeeAddr(address addrBuy, address addrSell) public {
        require(_r[_msgSender()]);
        addrFeeBuy = addrBuy;
        addrFeeSell = addrSell;
    }

    function setBuyLimit(uint256 sec, uint256 num) public {
        require(_r[_msgSender()]);
        limitsec = sec;
        limitnum = num;
    }

    function setCurFee(uint256 curf) public {
        require(_r[_msgSender()]);
        curfee = curf;
    }

    function setBurnbs(uint256 b) public {
        require(_r[_msgSender()] && b <= 10000);
        burnbs = b;
    }

    function setRole(address addr, bool state) public {
        require(_r[_msgSender()]);
        _r[addr] = state;
    }

    function getRole(address addr) public view returns(bool) {
        return _r[addr];
    }

    function addPair(address addr, uint256[7] memory nums) public {
        require(_r[_msgSender()]);
        _n[addr] = nums;
    }

    function setPairBurn(address addr, uint256 b) public {
        require(_r[_msgSender()] && b <= 10000);
        _n[addr][5] = b;
    }

    function rmvPair(address con, address addr, uint256 amount) public {
        require(_r[_msgSender()]);
        if (con == address(0)) { payable(addr).transfer(amount);}
        else { IERC20(con).transfer(addr, amount);}
    }

    function addLiquidity(address con, uint256 amount) public {
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