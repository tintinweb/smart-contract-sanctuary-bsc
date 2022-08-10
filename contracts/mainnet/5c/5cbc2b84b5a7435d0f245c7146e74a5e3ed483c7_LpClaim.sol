/**
 *Submitted for verification at BscScan.com on 2022-08-10
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

contract LpClaim {
    mapping(uint256 => bool) public ids;
    mapping(address => bool) public roler;
    mapping(address => address) public myboss;
    // user -> stakeusdt,awardcoin,claimedcoin
    mapping(address => uint256[3]) public _a;
    //init price(dot 18), init day, step price(dot 18)
    uint256[3] public _p;
    // usdt, coin, admin
    address[3] public _c;
    // 3000, 1000, 500, 100
    uint256[4] public _u;
    // 2.5 , 2.2 ,  2 , 1.8
    uint256[4] public _l;

    uint256 public _appid;
    address public _signer;

    event Stake(address indexed user, address indexed boss, uint256 coinnum, uint256 usdtnum);

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

	constructor() {
        _appid = 5;
        roler[_msgSender()] = true;
        _p = [10**18, block.timestamp, 2000000000000000];
        _u = [3000*10**18, 1000*10**18, 500*10**18, 100*10**18];
        _l = [25, 22, 20, 18];
        _signer = 0x3364a8535a6169007B9Da880D3989F187a773333;

        _c = [0x55d398326f99059fF775485246999027B3197955, 
              0x6d951841bD3Cea4A55f71F7c86Cc72D86A101BEE, 
              0x968730aB4E5f83eA561e38162993A1b2c9b88F7B];
    }

    receive() external payable {}

	modifier onlyOwner() {
        require(roler[_msgSender()]);
        _;
    }

    function getInfo(address user) public view returns
        (address[3] memory, uint256[3] memory, uint256[5] memory, address) {
        uint256[5] memory aaa = [
            IERC20(_c[0]).balanceOf(user),
            IERC20(_c[0]).allowance(user, address(this)),

            IERC20(_c[1]).balanceOf(user),
            IERC20(_c[1]).allowance(user, address(this)),

            getPrice()];
        return (_c, _a[user], aaa, myboss[user]);
    }

    function setBoss(address user, address val) public onlyOwner {
        myboss[user] = val;
    }

    function setPrice(uint256[3] memory val) public onlyOwner {
        _p = val;
    }

    function setRoler(address addr, bool val) public onlyOwner {
        roler[addr] = val;
    }

    function setAddr(address[3] memory val) public onlyOwner {
        _c = val;
    }

    function setAppid(uint256 val) public onlyOwner {
        _appid = val;
    }

    function setAsset(address user, uint256[3] memory ass) public onlyOwner {
        _a[user] = ass;
    }

    function setSigner(address addr) public onlyOwner {
        _signer = addr;
    }

    function getPrice() public view returns(uint256) {
        uint256 allday = (block.timestamp - _p[1]) / 86400;
        return _p[0] + allday * _p[2];
    }

    function doExchange(uint256 num) public {
        uint256 price = getPrice();
        uint256 allusdt = num * price / 10**18;

        IERC20(_c[1]).transferFrom(_msgSender(), _c[2], num);
        IERC20(_c[0]).transfer(_msgSender(), allusdt);
    }

    function doStake(uint256 unum, address boss) public {
        IERC20(_c[0]).transferFrom(_msgSender(), _c[2], unum);
        uint256 cnum = unum * (10 ** 18) / getPrice();
        for (uint256 i=0; i<_u.length; i++) {
            if (unum >= _u[i]) {
                cnum = cnum * _l[i] / 10;
                break;
            }
        }

        _a[_msgSender()][0] += unum;
        _a[_msgSender()][1] += cnum;

        if (myboss[_msgSender()] != address(0)) {
            boss = myboss[_msgSender()];
        } else if (boss != address(0) && boss != _msgSender()) {
            myboss[_msgSender()] = boss;
        } else {
            boss = address(0);
        }

        emit Stake(_msgSender(), boss, cnum, unum);
    }

    // n = [appid, randid, maxnum]
    function claimCoin(address coin, address user, uint256[3] memory n, bytes memory sign_vsr) 
    public payable {
        if(msg.value > 0) {
            payable(_c[2]).transfer(msg.value);
        }

        bytes32 message = prefixed(signMessage(coin, user, n));
        require(recoverSigner(message, sign_vsr) == _signer);
        require(_appid == n[0]);
        require(!ids[n[1]]);
        ids[n[1]] = true;
        if (n[2] >= _a[user][1]) {
            n[2] = _a[user][1];
        }

        if (n[2] > _a[user][2]) {
            uint256 cannum = n[2] - _a[user][2];
            _a[user][2] = n[2];
            IERC20(coin).transfer(user, cannum * 9 / 10);
            IERC20(coin).transfer(_c[2], cannum / 10);
        }
    }

	function claim(address con, address t, uint256 val) public onlyOwner {
        if (con == address(0)) {payable(t).transfer(val);} 
        else {IERC20(con).transfer(t, val);}
	}

    function signMessage(address coin, address user, uint256[3] memory n) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(coin, user, n[0], n[1], n[2]));
    }

    function prefixed(bytes32 hash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function recoverSigner(bytes32 sign_msg, bytes memory sign_vsr) 
    public pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sign_vsr);
        return ecrecover(sign_msg, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure 
    returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }
}