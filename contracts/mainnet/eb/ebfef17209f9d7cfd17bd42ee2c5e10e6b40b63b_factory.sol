/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

/*SPDX-License-Identifier: UNLICENSED*/
pragma solidity ^0.7.6;

interface IERC20 {
    function balanceOf(address owner) external view returns (uint);
}

contract factory{
    address public owner;
    address[] idos;

    //if no withdrawals : usless params (_token, _numDays, _pourLock)=(address(0),0,0)
    //if if no whitlisting : _whiAlloc=0 && _maxBuyWhi=0
    //if withdraw without vesting : _numDays=0 && _pourLock=0
    //if withdrawal project owner has to send tokens to the ido contract
    /*
    _maxBuyWhi : max buy amount for whitlisted users
    _whiAlloc : whitlisted garenteed allocation
    _maxBuyPub : max buy when it opens for public
    _numDays : vesting duration in days
    _pourLock : % of vested tokens at launch
    */
    function launchIdo(address _projectOwner, address _payment, address _token, uint _price, uint _idoStart, uint _idoEnd, uint _hardCap, uint _softCap, uint _maxBuyWhi, uint _whiAlloc, uint _maxBuyPub, uint _numDays, uint _pourLock) external{
        require(msg.sender == owner,"owner only");
        ido newIdo = new ido(owner, _projectOwner, _payment, _token, _price, _idoStart, _idoEnd, _hardCap, _softCap, _maxBuyWhi, _whiAlloc, _maxBuyPub, _numDays, _pourLock);
        idos.push(address(newIdo));
    }

    function getLength() public view returns(uint) {
        return idos.length;
    }

    function getIdo(uint pos) public view returns (address) {
        return idos[pos];
    }

    function getIdos() public view returns(address[] memory) {
        return idos;
    }

    constructor(address _multiSigAddress ) {
        owner = _multiSigAddress;
    }
}

contract ido {
    using SafeMath for uint;

    address owner;
    address public payment;
    address public token;
    address public projectOwner;

    mapping(address=>uint) paid;
    mapping(address=>uint) tokenBought;
    mapping(address=>uint) staked;
    mapping(address=>bool) whitelisted;
    mapping(address=>bool) reserved;
    mapping(address=>uint) maxBuyTier;

    uint public price;
    uint idoStart;
    uint idoEnd;
    uint public hardCap;
    bool refund;
    uint public totalPaid;

    uint maxBuyWhi;
    uint maxBuyPub;
    uint whiAlloc;
    uint totalStaked;

    bool public snapshoted;
    address[] stakers;

    uint softCap;
    uint numDays;
    uint pourLock;

    function buyIdo(uint amount) external {
        require(block.timestamp >= idoStart, "not started yet");
        require(block.timestamp <= idoEnd, "already finished");
        require(amount <= getMaxEntry(msg.sender), "you cant buy this amount");
        paid[msg.sender] = paid[msg.sender].add(amount);
        tokenBought[msg.sender] = tokenBought[msg.sender].add(amount.mul(1e18).div(price));
        totalPaid = totalPaid.add(amount);
        TransferHelper.safeTransferFrom(payment, msg.sender, address(this), amount);
    }

    //withdraw token if it's in the contract
    function withdraw(uint amount) external {
        require(block.timestamp >= idoEnd, "not finished yet");
        require(amount <= canWithdraw(), "you cant buy this amount");
        require(totalPaid >= softCap, "softcap not reached");
        tokenBought[msg.sender] = tokenBought[msg.sender].sub(amount);
        TransferHelper.safeTransfer(token, msg.sender, amount);
    }

    //get max amount you can withdraw from token 
    function canWithdraw() public view returns(uint) {
        if (block.timestamp >= idoEnd+numDays*1 days) {
            return tokenBought[msg.sender];
        } else if (block.timestamp >= idoEnd && block.timestamp < idoEnd.add(numDays.mul(1 days))) {
            return paid[msg.sender].mul(1e18).mul(pourLock).mul(block.timestamp.sub(idoEnd)).div(price.mul(1 days).mul(100).mul(price).mul(numDays)).add(tokenBought[msg.sender]).sub(paid[msg.sender].mul(1e18).mul(pourLock).div(price.mul(100)));
        } else {
            return 0;
        }
    }

    function getMaxEntry(address who) internal view returns(uint) {
        uint amountLeft = hardCap.sub(totalPaid);
        uint maxBuy = 0;

        if(totalStaked>0) maxBuy = staked[who].mul(hardCap.sub(whiAlloc)).div(totalStaked);
        if(block.timestamp >= idoStart.add(1 hours)) {
            //public
            if(reserved[who] && whitelisted[who]) {
                if(amountLeft<=maxBuy.add(maxBuyWhi).add(maxBuyTier[who]).sub(paid[who])) return amountLeft;
                return maxBuy.add(maxBuyWhi).add(maxBuyTier[who]).sub(paid[who]);
            } else if(reserved[who]) {
                if(amountLeft<=maxBuy.add(maxBuyTier[who]).sub(paid[who])) return amountLeft;
                return maxBuy.add(maxBuyTier[who]).sub(paid[who]);
            } else if(whitelisted[who]) {
                if(amountLeft<=maxBuyWhi.add(maxBuyPub).sub(paid[who])) return amountLeft;
                return maxBuyWhi.add(maxBuyPub).sub(paid[who]);
            } else {
                if(amountLeft<=maxBuyPub.sub(paid[who])) return amountLeft;
                return maxBuyPub.sub(paid[who]);
            }
        } else if(block.timestamp >= idoStart.add(30 minutes)) {
            if(reserved[who] && whitelisted[who]) {
                if(amountLeft<=maxBuy.add(maxBuyWhi).sub(paid[who])) return amountLeft;
                return maxBuy.add(maxBuyWhi).sub(paid[who]);
            } else if(reserved[who]) {
                if(amountLeft<=maxBuy.sub(paid[who])) return amountLeft;
                return maxBuy.sub(paid[who]);
            } else if(whitelisted[who]) {
                if(amountLeft<=maxBuyWhi.sub(paid[who])) return amountLeft;
                return maxBuyWhi.sub(paid[who]);
            } else {
                return 0;
            }
        }else if(block.timestamp>=idoStart){
            if(reserved[who]) {
                if(amountLeft<=maxBuy.sub(paid[who])) return amountLeft;
                return maxBuy.sub(paid[who]);
            } else {
                return 0;
            }
        }else{
            if(reserved[who]) {
                if(amountLeft<=maxBuy.sub(paid[who])) return amountLeft;
                return maxBuy.sub(paid[who]);
            } else {
                return 0;
            }
        }
    }
    
    //snapshot satkers    
    function whitelist (address[] calldata user,uint[] calldata stake) external {
        require(msg.sender == owner);
        snapshoted = true;
        for (uint i; i < user.length; i++) {
            if(reserved[user[i]]){
                if(stake[i] >= 500000e18) {
                    staked[user[i]]=stake[i].mul(3);
                    totalStaked=totalStaked.add(stake[i].mul(3));
                    maxBuyTier[user[i]]=maxBuyPub.mul(3);
                } else if(stake[i] >= 100000e18) {
                    staked[user[i]] = stake[i].mul(15).div(10);
                    totalStaked = totalStaked.add(stake[i].mul(15).div(10));
                    maxBuyTier[user[i]] = maxBuyPub.mul(15).div(10);
                }else if(stake[i] >= 1e18) {
                    staked[user[i]] = stake[i];
                    totalStaked=totalStaked.add(stake[i]);  
                    maxBuyTier[user[i]] = maxBuyPub;
                }
            }
        }
    }
    
    //whitlisting
    function whiteliste (address[] calldata user,bool x) external {
        require(msg.sender == owner);
        for (uint i; i < user.length; i++) {
            whitelisted[user[i]]=x;
        }
    }

    //reservation for stakers
    function reservation() external {
        require(!snapshoted && !reserved[msg.sender]);
        reserved[msg.sender] = true;
        stakers.push(msg.sender);
    }
    
    function finish() external {
        require(msg.sender == owner && block.timestamp >= idoEnd && !refund);
        IERC20 erc = IERC20(payment);
        TransferHelper.safeTransfer(payment, owner, erc.balanceOf(address(this))/10); //10% fees
        TransferHelper.safeTransfer(payment, projectOwner, erc.balanceOf(address(this)));
    }   

    function withdrawNotSold() external {
        require(projectOwner == msg.sender,"project owner only");
        require(block.timestamp >= idoEnd,"not finished yet");
        if(token != address(0)){
            IERC20 erc = IERC20(token);
            if(totalPaid >= softCap) {
                TransferHelper.safeTransfer(token, projectOwner,  erc.balanceOf(address(this))-totalPaid*1e18/price);
            } else {
                TransferHelper.safeTransfer(token, projectOwner, erc.balanceOf(address(this)));
            }
        }
    }

    function refunding(bool x) external {
        require(msg.sender == owner && block.timestamp >= idoEnd);
        refund = x;
    }

    //withdraw refund
    function getRefund() external {
        require(refund || (totalPaid < softCap && block.timestamp >= idoEnd), "no refund");
        TransferHelper.safeTransfer(payment, msg.sender, paid[msg.sender]);

        paid[msg.sender] = 0;
    }

    function getInfo() public view returns(uint, uint, uint, uint, uint, bool) {
        return (paid[msg.sender], paid[msg.sender].mul(1e18).div(price), tokenBought[msg.sender], getMaxEntry(msg.sender), getProgress(), reserved[msg.sender]);
    }

    function getProgress() public view returns(uint) {
        return totalPaid.mul(100).div(hardCap);
    }
    
    //owner only functions
    function getInfoAdmin(address who) public view returns(uint, uint, uint, uint, bool, uint) { //returns spl address, amount paid in usdt,amount token bought,staked amount in total,current maxBuy
        require(msg.sender == owner);
        return (paid[who], paid[who].mul(1e18).div(price), staked[who], getMaxEntry(who), reserved[who], tokenBought[who]);
    }
    function getStakers() public view returns(address[] memory) {
        require(msg.sender == owner);
        return stakers;
    }

    constructor(address _owner, address _projectOwner, address _payment, address _token, uint _price, uint _idoStart, uint _idoEnd, uint _hardCap, uint _softCap, uint _maxBuyWhi, uint _whiAlloc, uint _maxBuyPub, uint _numDays, uint _pourLock){
        owner = _owner;
        projectOwner = _projectOwner;
        payment = _payment;
        token = _token;
        price = _price;
        idoStart = _idoStart;
        idoEnd = _idoEnd;
        hardCap = _hardCap;
        maxBuyWhi = _maxBuyWhi;
        whiAlloc = _whiAlloc;
        maxBuyPub = _maxBuyPub;
        softCap = _softCap;
        numDays = _numDays;
        pourLock = _pourLock;
    }
}

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

}

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "overflow");
    }

    function div(uint x, uint y) internal pure returns (uint z) {
            require(y > 0 , "dib by 0");
            z = x / y;
    }
}