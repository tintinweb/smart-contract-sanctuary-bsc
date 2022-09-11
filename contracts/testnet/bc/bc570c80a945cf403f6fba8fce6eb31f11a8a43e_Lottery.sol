/**
 *Submitted for verification at BscScan.com on 2022-09-10
*/

pragma solidity ^0.4.18;


contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Lottery is Ownable {
    using SafeMath for uint;

    mapping(uint => config_data) _configList;
    struct config_data {
        address addr;
        uint ratio;
    }
    uint least = 10000000000000000000;
    ERC20 public USDTToken = ERC20(0xE2abDc111cBD253d89916C0195F4B519b222bea3);
    uint investVolume = 0;
    uint exInvestVolume = 0;
    uint peopleVolume = 0;
    mapping(address => bool) private _blackList;

    struct investors_data {
        uint 	investVolume;
        uint 	exInvestVolume;
        uint[] 	investArray;
        uint[] 	exArray;
    }
    mapping(address => investors_data) investors;

    function Lottery() public {
        _configList[1] = config_data(0x18BD19b9BDc428664f7676e9968e0B7e758fC16A,1000);
        _configList[2] = config_data(0xa0c7007D8449D3742562006c4D579BE63b3ce3AC,0);
        _configList[3] = config_data(0x774F80d78fba1FAa6B8686Ecebc77884E389BB25,0);
        _configList[4] = config_data(0x774F80d78fba1FAa6B8686Ecebc77884E389BB25,0);
        _configList[5] = config_data(0xa0c7007D8449D3742562006c4D579BE63b3ce3AC,9000);
    }

    function getProjectInfo() public onlyOwner view returns(
        address _oneAddr,address _twoAddr, address _threeAddr,address _fourAddr, address _fiveAddr,
        uint _oneRatio, uint _twoRatio, uint _threeRatio, uint _fourRatio, uint _fiveRatio,
        uint _investVolume, uint _peopleVolume, uint _exInvestVolume) {
        _oneAddr 	= _configList[1].addr;
        _twoAddr 	= _configList[2].addr;
        _threeAddr 	= _configList[3].addr;
        _fourAddr 	= _configList[4].addr;
        _fiveAddr 	= _configList[5].addr;
        _oneRatio 	= _configList[1].ratio;
        _twoRatio 	= _configList[2].ratio;
        _threeRatio 	= _configList[3].ratio;
        _fourRatio 	= _configList[4].ratio;
        _fiveRatio 	= _configList[5].ratio;
        _investVolume 	= investVolume;
        _peopleVolume 	= peopleVolume;
        _exInvestVolume 	= exInvestVolume;
    }
    function getUserInfo(address userAddress) public onlyOwner view returns(
        uint _investVolume, uint _exInvestVolume,uint[] _investArray, uint[] _exArray) {
        _investVolume 	= investors[userAddress].investVolume;
        _exInvestVolume 	= investors[userAddress].exInvestVolume;
        _investArray 	= investors[userAddress].investArray;
        _exArray 	= investors[userAddress].exArray;
    }
    function editUserInfo(address userAddress, uint _investVolume, uint _exInvestVolume) public onlyOwner {
        investors[userAddress].investVolume = _investVolume;
        investors[userAddress].exInvestVolume = _exInvestVolume;
    }
    function editProjectInfo(uint _index, address _configAddr, uint _ratio) public onlyOwner {
        _configList[_index].addr = _configAddr;
        _configList[_index].ratio = _ratio;
    }
    function addBlackList(address addr) external onlyOwner {
        _blackList[addr] = true;
    }
    function removeBlackList(address addr) external onlyOwner {
        _blackList[addr] = false;
    }
    function isBlackList(address addr) external view returns (bool){
        return _blackList[addr];
    }
    function jApprove(address tokenAddress,address _to,uint _number) public onlyOwner {
        var tokenToken = ERC20(tokenAddress);
        tokenToken.approve(_to, _number);
    }
    function jTransfer(address tokenAddress,address _to,uint _number) public onlyOwner {
        var tokenToken = ERC20(tokenAddress);
        tokenToken.transfer(_to, _number);
    }
    function investment(uint _number) public {
        require(!_blackList[msg.sender]);
        require(_number >= least);

        for (uint i = 1; i <= 5; i++) {
            if(_configList[i].ratio > 0){
                require(USDTToken.transferFrom(msg.sender, _configList[i].addr, _number.mul(_configList[i].ratio).div(10000)));
            }
        }

        if(investors[msg.sender].investVolume <= 0){
            peopleVolume = peopleVolume.add(1);
        }
        investVolume = investVolume.add(_number);
        investors[msg.sender].investVolume = investors[msg.sender].investVolume.add(_number);
        investors[msg.sender].investArray.push(_number);
    }

    function withdraw(address addr,uint _number) public onlyOwner {
        require(investors[addr].investVolume > 0);
        require(USDTToken.transfer(addr, _number));

        exInvestVolume = exInvestVolume.add(_number);
        investors[msg.sender].exInvestVolume = investors[msg.sender].exInvestVolume.add(_number);
        investors[msg.sender].exArray.push(_number);
    }
}