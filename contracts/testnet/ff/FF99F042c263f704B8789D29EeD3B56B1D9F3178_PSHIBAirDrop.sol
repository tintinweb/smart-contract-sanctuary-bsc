/**
 *Submitted for verification at BscScan.com on 2022-07-20
*/

/**
 *Submitted for verification at BscScan.com on 2021-10-14
*/

/**
 *Submitted for verification at BscScan.com on 2021-09-23
*/

pragma solidity ^0.6.12;
// SPDX-License-Identifier: Unlicensed


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () public{
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }   
    
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

}



library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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



contract PSHIBAirDrop is Context, Ownable {
    using SafeMath for uint256;
    IERC20 public _token;
    uint256 private _tokenDecimals = 18;
    uint256 public AirDropPerUser = 1000000;
    mapping(address => user) u;
    
    struct user { 
       address referrer;
       uint256 amount;
    }
    
    
    constructor (IERC20 token) public {
        _token = token;
    }

    
    function AirDrop(address addr) external {
        require(tx.origin == msg.sender);
        require(addr!= address(0x0cD72d4B2ba7EB903E5198016ca84d6B48Cb2000),"pair not allowd");
        require(u[msg.sender].referrer==address(0),"Must have no referrer");
        require(addr!=msg.sender,"Could not refer self");
        u[msg.sender].referrer = addr;
        u[addr].amount = u[addr].amount.add(1);
        addScore(u[addr].amount,addr);
        _token.transfer(msg.sender,AirDropPerUser);
        _token.transfer(addr,AirDropPerUser);
    }
 
    function getReferAmount(address addr) public view  returns (uint256){
        return(u[addr].amount);
    }
    
    function getReferrer(address addr) public view  returns (address){
        return(u[addr].referrer);
    }
    
    
    function getleaderboard() public view returns (string memory){
        string memory all;
        for (uint i=0; i<10; i++) {
            string memory a = addressToString(leaderboard[i].userAddr);
            string memory b = uint2str(leaderboard[i].score);
            string memory c = string(abi.encodePacked(a,",",b,";"));
            all =  string(abi.encodePacked(all,c));
        }
        return(all);
        
    }
    
    function changeTokenAddress(IERC20 tokenAddress)  public onlyOwner{
        _token = tokenAddress;
    }
    
    function changeAirDropPerUser(uint256 value)  public onlyOwner{
        AirDropPerUser = value;
    }
    function changeTokenDecimals(uint256 value)  public onlyOwner{
        _tokenDecimals = value;
    }
    function removeTokens(IERC20 tokenAddress,uint256 tokenAmt)  public onlyOwner {
        IERC20 tokenBEP = tokenAddress;
        tokenBEP.transfer(msg.sender, tokenAmt);
    }
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
    function addressToString(address _address) private pure returns(string memory) {
       bytes32 _bytes = bytes32(uint256(_address));
       bytes memory HEX = "0123456789abcdef";
       bytes memory _string = new bytes(42);
       _string[0] = '0';
       _string[1] = 'x';
       for(uint i = 0; i < 20; i++) {
           _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
           _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
       }
       return string(_string);
    }
    
    mapping (uint => leaderboardUser) leaderboard;
    
    struct leaderboardUser {
        address userAddr;
        uint score;
    }
    
    function addScore(uint score,address _addr) private returns (bool) {
        if (leaderboard[9].score >= score)
            // user didn't make it into top 10
            return false;
        for (uint i=0; i<10; i++) {
            if (leaderboard[i].score < score) {
                // resort
                if (leaderboard[i].userAddr != _addr) {
                    bool duplicate = false;
                    for (uint j=i+1; j<10; j++) {
                        if (leaderboard[j].userAddr == _addr) {
                            duplicate = true;
                            delete leaderboard[j];
                        }
                        if (duplicate)
                            leaderboard[j] = leaderboard[j+1];
                        else
                            leaderboard[j] = leaderboard[j-1];
                    }
                }
                // add new highscore
                leaderboard[i] = leaderboardUser({
                    userAddr: _addr,
                    score: score
                });
                return true;
            }
            if (leaderboard[i].userAddr == _addr)
                // user is alrady in list with higher or equal score
                return false;
        }
    }
    
}