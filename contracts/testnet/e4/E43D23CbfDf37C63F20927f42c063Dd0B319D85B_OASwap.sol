// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

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

interface IToken {
    function _tBurnFeeTotal() external view returns (uint256);
    function _maxBurnFee() external view returns (uint256);
}

contract OASwap {
    address public coinbs; // dot 18
    uint256 public burnbs; // dot 4, burn 14% = 1400
    mapping(address => mapping(address => mapping(uint256 => SwapCoinNum)))public swapCoinNums;
    mapping(address => mapping(uint256 => uint256)) public maxPrices;

    // coin => price(dot 18), step(dot 18), initprice(dot 18), dot, stime, burn(dot 4)
    mapping(address => uint256[8]) _n;
    mapping(address => bool) _r;

    struct SwapCoinNum {
        uint256 buyCoinNum;
        uint256 sellCoinNum;
    }

    constructor() {
        _r[_msgSender()] = true;
    }

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    event Swap(address indexed a1, address indexed a2, uint256 amount, uint256 p1, uint256 p2);

    function setBaseAddr(address a1) public {
        require(_r[_msgSender()]);
        coinbs = a1;
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

    function addPair(address addr, uint256[8] memory nums) public {
        require(_r[_msgSender()]);
        _n[addr] = nums;
    }

    function setPairBurn(address addr, uint256 b) public {
        require(_r[_msgSender()] && b <= 10000);
        _n[addr][5] = b;
    }

    function setSwapLimit(address addr, uint256 l) public {
        _n[addr][7] = l;
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
    (uint256[8] memory, uint256[4] memory, uint256) {
        uint256[4] memory assets = [
            IERC20(addr).balanceOf(_msgSender()),
            IERC20(addr).allowance(_msgSender(), address(this)),
            IERC20(coinbs).balanceOf(_msgSender()),
            IERC20(coinbs).allowance(_msgSender(), address(this))];
        return (_n[addr], assets, IERC20(addr).balanceOf(address(this)));
    }

    function swap(address a1, address a2, uint256 coinNum) public payable {
        if (a1 == coinbs) {
            require(_n[a2][4] < block.timestamp && _n[a2][0] > 0);
            uint256 todayIndex = block.timestamp / (24 * 60 * 60);
            SwapCoinNum storage swapCoinNum = swapCoinNums[a2][_msgSender()][todayIndex];

            // buy basecoin -> coin   basecoin = usdt | tts
            IERC20(coinbs).transferFrom(_msgSender(), address(this), coinNum);

            uint256 baseNum = coinNum * (10000 - burnbs) / 10000;
            
            coinNum = getGen1Y2C(_n[a2][0], _n[a2][1], baseNum, _n[a2][3]);
            swapCoinNum.buyCoinNum += coinNum;
            require(swapCoinNum.buyCoinNum <= _n[a2][7]);

            uint256 pStep = getStep(a2, coinNum);
            uint256 pre_price = _n[a2][0];
            uint256 new_price = _n[a2][0] + pStep;
            _n[a2][0] = new_price;
            
            uint256 todayMaxPrice = maxPrices[a2][todayIndex];

            if (todayMaxPrice == 0) {
                maxPrices[a2][todayIndex] = new_price;
            } else if (new_price > todayMaxPrice) {
                maxPrices[a2][todayIndex] = new_price;
            }

            IERC20(a2).transfer(_msgSender(), coinNum);
            emit Swap(a1, a2, baseNum, pre_price, new_price);
        } else if (a2 == coinbs) {
            require(_n[a1][4] < block.timestamp && _n[a1][0] > 0);
            uint256 todayIndex = block.timestamp / (24 * 60 * 60);
            SwapCoinNum storage swapCoinNum = swapCoinNums[a1][_msgSender()][todayIndex];

            uint256 burnNum = coinNum * _n[a1][6] / 10000;
            uint256 leftBurnFee =  IToken(a1)._maxBurnFee() - IToken(a1)._tBurnFeeTotal();

            // sell coin -> basecoin
            IERC20(a1).transferFrom(_msgSender(), address(this), coinNum);
            swapCoinNum.sellCoinNum += coinNum;
            require(swapCoinNum.sellCoinNum <= _n[a1][7]);
            
            if (leftBurnFee >= burnNum) {
                coinNum = coinNum * (10000 - _n[a1][5]) / 10000;
            } else if (leftBurnFee != 0) {
                coinNum = coinNum * (10000 - _n[a1][5] + _n[a1][6]) / 10000 - leftBurnFee;
            }

            (uint256 baseNum,uint256  pStep) = getBaseNumAndStep(a1, coinNum, 1);
            uint256 pre_price = _n[a1][0];
            uint256 new_price = _n[a1][0] - pStep;
            _n[a1][0] = new_price;
            require(new_price >= _n[a1][2]);

            uint256 todayMaxPrice = maxPrices[a1][todayIndex];
            if (todayMaxPrice == 0) {
                 maxPrices[a1][todayIndex] = pre_price;
            } 
            require(maxPrices[a1][todayIndex] / 2 <= new_price);

            IERC20(coinbs).transfer(_msgSender(), baseNum);

            emit Swap(a1, a2, baseNum, pre_price, new_price);
        }
    }

    receive() external payable {}

    // coin addr & coin num & kind = 0 = buy, kind = 1 = sell
    function getBaseNumAndStep(address addr, uint256 coins, uint256 kind) 
    public view returns(uint256, uint256) {
        uint256 pStep = getStep(addr, coins);
        uint256 pAvg;
        if (kind == 1) {pAvg = _n[addr][0] - (pStep  / 2);
        } else {pAvg = _n[addr][0] + (pStep  / 2);}
        uint256 ttsAmount = coins * pAvg / 10 ** _n[addr][3];
        return (ttsAmount, pStep);
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