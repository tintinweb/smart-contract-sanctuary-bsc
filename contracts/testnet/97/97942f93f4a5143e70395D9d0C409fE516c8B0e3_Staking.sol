/**
 *Submitted for verification at BscScan.com on 2022-10-10
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value)external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function burn(uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Staking {
    uint256[] public pools = [12,18,30,48,60]; // 15
    uint256[] public per = [2,3,4,5,6];
    mapping(address => mapping(uint256 => bool)) public isactivate;
    
    address public USDT;
    address public owner;
    address public admin;

    uint256 public minimumBuy = 100 * 10 ** 18;
    uint256 public blockcount = 1000;  // 889100
    
    struct USER{
        address _user;
        uint256 stakingamount;
        uint256 percentages;
        uint256 stakingperiod;
        uint256 activateTime;
        uint256 activateRate;
        uint256 nextclaimtime;
        uint256 isclaim;
    }
    mapping(uint256 => USER) public user;
    uint256 public stakingid;

    constructor (address _busd,address _admin) {
        USDT = _busd;
        owner = msg.sender;
        admin = _admin;
    }
    event staking(address user,uint256 pool,uint256 count,uint256 stakingAmount);

    function Stake(uint256 _index,uint256 amount,uint256 _activateRate,bytes memory signature) public returns(bool){
        require(verify(admin,address(this),_index,amount,_activateRate,signature),"not user call the function");
        uint256 poolsid = _index - 1;
        require(pools.length > poolsid,"is not pools valid");
        require(amount >= 100 * 10 ** 18 ,"is not valid enter amount");
        require((amount % (100 * 10 ** 18)) == 0,"is not valid enter amount");
        stakingid = stakingid + 1;
        uint256 _a = (amount * 10 ** 18) / _activateRate;
        user[stakingid] = USER({_user : msg.sender,
                            stakingamount : amount,
                            percentages : per[poolsid],
                            stakingperiod : pools[poolsid],
                            activateTime : block.number,
                            activateRate : _activateRate,
                            nextclaimtime : block.number + blockcount,
                            isclaim : 0
                            });
        require(IERC20(USDT).balanceOf(msg.sender) >= _a,"insufficient balance in user");
        require(IERC20(USDT).transferFrom(msg.sender,address(this),_a),"is not appove the contract");
        
        emit staking(msg.sender,pools[poolsid],stakingid,amount);
        return true;
    }
    function IsClaim(uint256 _stakingid) public view returns(bool){
        return (user[_stakingid].nextclaimtime < block.number) ;
    }
    event claim(uint256 index,uint256 cliamamount,uint256 sendamount,uint256 nextclaimtime);
    function Claim(uint256 _stakingid,uint256 _stakingamount,uint256 _price,bytes memory signature) public returns(bool){
        require(verify(admin,address(this),_stakingid,_stakingamount,_price,signature),"not user call the function");
        require(user[_stakingid]._user == msg.sender,"is not call user call");
        require(user[_stakingid].isclaim < user[_stakingid].stakingperiod ,"is not call user call");
        require(user[_stakingid].nextclaimtime < block.number,"is not call user call");
        require(user[_stakingid].stakingamount == _stakingamount,"is not same stakingamount input");

        uint256 _a = (user[_stakingid].stakingamount * user[_stakingid].percentages)/100;
        uint256 _s = (_a * 10 ** 18) / _price ;

        IERC20(USDT).transfer(msg.sender,_s);

        user[_stakingid].nextclaimtime = user[_stakingid].nextclaimtime + blockcount ;
        user[_stakingid].isclaim = user[_stakingid].isclaim + 1;

        emit claim( _stakingid,_a, _s, user[_stakingid].nextclaimtime);

        if(user[_stakingid].isclaim == user[_stakingid].stakingperiod){
            Unstake( _stakingid, _stakingamount, _price,signature);
        }
        
        return true;
    }

    event unstake(uint256 index,uint256 stakeamount,uint256 sendamount);

    function Unstake(uint256 _stakingid,uint256 _stakingamount,uint256 _price,bytes memory signature) public returns(bool){
        require(verify(admin,address(this),_stakingid,_stakingamount,_price,signature),"not user call the function");
        require(user[_stakingid]._user == msg.sender,"is not call user call");
        require(user[_stakingid].isclaim == user[_stakingid].stakingperiod ,"is not call user call");
        require(user[_stakingid].stakingamount == _stakingamount,"is not same stakingamount input");
        
        uint256 _s = (_stakingamount * 10 ** 18) / _price ;

        require(IERC20(USDT).balanceOf(address(this)) >= _s,"insufficient balance in user");
        IERC20(USDT).transfer(msg.sender,_s);
        emit unstake( _stakingid, _stakingamount, _s);
        return true;
    }
    function chnageTimeLock(uint256 _timelock) public returns(bool){
        require(msg.sender == admin,"is not owner !!!");
        blockcount = _timelock;
        return true;
    }
    function Withdraw(address _address,uint256 _amount) public returns (bool) {
        require(msg.sender == admin,"is not owner !!!");
        payable(_address).transfer(_amount);
        return true;
    }
    function Withdraw(address _contract,address _user) public returns (bool) {
        require(msg.sender == admin,"is not owner !!!");
        IERC20(_contract).transfer(_user,IERC20(_contract).balanceOf(address(this)));
        return true;
    }
    receive() external payable {}
    function changeuser(address _user,uint256 _index) public returns(bool){
        require(msg.sender == owner,"is not owner !!!");
        isactivate[_user][pools[_index-1]] = false;
        return true;
    }
    function changetokenaddress(address _busd) public returns (bool){
        require(msg.sender == owner,"is not owner !!!");
        USDT = _busd;
        return true;
    }

    function getMessageHash(
        address _contractaddress,
        uint _index,
        uint _amount,
        uint _activateRate
    ) public pure returns (bytes32) {
        // require(!iscodeuse[code],"code is use");
         // keccak256(abi.encodePacked('Solidity')) == keccak256(abi.encodePacked(_language))
        return keccak256(abi.encodePacked(_contractaddress, _index, _amount, _activateRate));
    }
    function getEthSignedMessageHash(bytes32 _messageHash)
        private
        pure
        returns (bytes32)
    {
        /*
        Signature is produced by signing a keccak256 hash with the following format:
        "\x19Ethereum Signed Message\n" + len(msg) + msg
        */
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash)
            );
    }
    
    function verify(
        address _signer,
        address _contractaddress,
        uint _index,
        uint _amount,
        uint _activateRate,
        bytes memory signature
    ) public pure returns (bool) {
        bytes32 messageHash = getMessageHash(_contractaddress, _index, _amount, _activateRate);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recoverSigner(ethSignedMessageHash, signature) == _signer;
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature)
        private
        pure
        returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig)
        private
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        require(sig.length == 65, "invalid signature length");

        assembly {
            /*
            First 32 bytes stores the length of the signature

            add(sig, 32) = pointer of sig + 32
            effectively, skips first 32 bytes of signature

            mload(p) loads next 32 bytes starting at the memory address p into memory
            */

            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }

        // implicitly return (r, s, v)
    }

    

}