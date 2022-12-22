pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title EternalStorage
 * @dev This contract holds all the necessary state variables to carry out the storage of any contract.
 */
contract EternalStorage {
    mapping(bytes32 => uint256) internal uintStorage;
    mapping(bytes32 => string) internal stringStorage;
    mapping(bytes32 => address) internal addressStorage;
    mapping(bytes32 => bytes) internal bytesStorage;
    mapping(bytes32 => bool) internal boolStorage;
    mapping(bytes32 => int256) internal intStorage;

}

interface ISparkyVIPDirectory {
    function isSparkyVIP(address _vip) external view returns (bool);
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract ERC677 is ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value, bytes data);

    function transferAndCall(address, uint256, bytes) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool);
}

contract IBurnableMintableERC677Token is ERC677 {
    function mint(address _to, uint256 _amount) public returns (bool);
    function burn(uint256 _value) public;
    function claimTokens(address _token, address _to) external;
}

contract HomeFeeManagerMultiAMBErc20ToErc677Ext is EternalStorage{
    using SafeMath for uint256;


    constructor() public {
    }

    function getSparkyVIPDirectory() public pure returns (address) {
        return 0x22200fcBc7A35f5B8043599593b911C98fcAaD6f; // MAINNET: 0x32e14D0C380490de898a84538E087a96bE81DB0f
    }

    function getSFUELAddress() public pure returns (address) {
        return 0x17DfDF426b7E994FB82855E052e3c2D4248ff496; // MAINNET: 0x37Ac4D6140e54304D77437A5c11924f61a2D976f
    }

    function calculateFee(bytes32 _feeType, address _token, uint256 _value, address _receiver) public view returns (uint256, bool) {
        uint256 _fee = getFee(_feeType, _token, ISparkyVIPDirectory(getSparkyVIPDirectory()).isSparkyVIP(_receiver));
        uint256 _calFee = _value.mul(_fee).div(1 ether);
        uint256 _sfuelFee = uintStorage[keccak256(abi.encodePacked("sfuelFee",_feeType))];

        if (_sfuelFee == 0) return (_calFee, false);

        if(ERC20(getSFUELAddress()).allowance(_receiver, msg.sender) >= _sfuelFee && ERC20(getSFUELAddress()).balanceOf(_receiver) >= _sfuelFee){
            return (_sfuelFee, true);
        }
        else{
            return (_calFee, false);
        }
    }

    function getFee(bytes32 _feeType, address _token, bool _isDiscounted) public view returns (uint256) {
        uint256 _fee;
        if (_isDiscounted) _fee = uintStorage[keccak256(abi.encodePacked(_feeType, _token, "discounted"))];
        else _fee = uintStorage[keccak256(abi.encodePacked(_feeType, _token))];
        return _fee;
    }

    function distributeFee(bytes32 _feeType, address _token, uint256 _value, address _receiver) public returns (uint256) {
        uint256 numOfAccounts = uintStorage[0xabc77c82721ced73eef2645facebe8c30249e6ac372cce6eb9d1fed31bd6648f];
        (uint256 _fee, bool _useSFUEL) = calculateFee(_feeType, _token, _value, _receiver);
        if (numOfAccounts == 0 || _fee == 0) {
            return 0;
        }
        uint256 feePerAccount = _fee.div(numOfAccounts);
        uint256 randomAccountIndex;
        uint256 diff = _fee.sub(feePerAccount.mul(numOfAccounts));
        if (diff > 0) {
            randomAccountIndex = uint256(blockhash(block.number.sub(1))) % numOfAccounts;
        }

        address nextAddr = addressStorage[keccak256(abi.encodePacked("rewardAddressList", 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF))];
        require(nextAddr != 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF && nextAddr != address(0));

        uint256 i = 0;
        while (nextAddr != 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF) {
            uint256 feeToDistribute = feePerAccount;
            if (diff > 0 && randomAccountIndex == i) {
                feeToDistribute = feeToDistribute.add(diff);
            }

            if(_useSFUEL && _feeType == 0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26){
                ERC677(getSFUELAddress()).transferFrom(_receiver, nextAddr, feeToDistribute);
            } else if (_feeType == 0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26) {
                ERC677(_token).transfer(nextAddr, feeToDistribute);
            } else {
                IBurnableMintableERC677Token(_token).mint(nextAddr, feeToDistribute);
            }

            nextAddr = addressStorage[keccak256(abi.encodePacked("rewardAddressList", nextAddr))];
            require(nextAddr != address(0));
            i = i + 1;
        }
        if (_useSFUEL && _feeType == 0x741ede137d0537e88e0ea0ff25b1f22d837903dbbee8980b4a06e8523247ee26) _fee = 0;
        return _fee;
    }
}