// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "./StakePool.sol";

interface IStakePool {
    function initialize(address _mainToken, address _pairToken, address _admin) external;
}

contract MainPool is Ownable {
    bytes32 public constant INIT_CODE_PAIR_HASH = keccak256(abi.encodePacked(type(StakePool).creationCode));
    using SafeMath for uint256;
    using SafeMath32 for uint32;

    uint256 decimal = 10 ** 18;
    address mainToken;

    mapping(address => mapping(address => address)) public getStakePool;
    address[] public allStakePools;


    address mainPool;

    event PairCreated(address indexed _main, address indexed _pair, address pair, uint);

    function setTokenMain(address _addr) public {
        require(_addr != address(0), "token is invali");
        mainToken = _addr;
        // YiToken(_addr).setMainPool(address(this));
    }

    //合约创建，只有管理员操作
    function createStakePool(address _pair) public onlyOwner returns (address _StakePool) {
        require(mainToken != address(0), " need a mainToken ... ");
        bytes memory bytecode = type(StakePool).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(mainToken, _pair));
        assembly {
            _StakePool := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IStakePool(_StakePool).initialize(mainToken, _pair, _msgSender());
        getStakePool[mainToken][_pair] = _StakePool;
        getStakePool[_pair][mainToken] = _StakePool; // populate mapping in the reverse direction
        allStakePools.push(_StakePool);
        emit PairCreated(mainToken, _pair, _StakePool, allStakePools.length);
    }

    function allocation () public {
        require(mainToken != address(0), "token is invali");
        YiToken(mainToken).mint(address(this));
    }

    function setAdmin(address _admin) external onlyOwner{
        transferOwnership(_admin);
    }

    function tranMainPool(address _new) external {
        require(_new != address(0));
        require(msg.sender == mainPool);
        mainPool = _new;
    }

    //给指定账号分配指定数量的币
    function allocTo(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0), " target address is null ... ");
        require(_amount > 0, " wrong amount ... ");

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _amount, " Insufficient balance ... ");
        bool res = YiToken(mainToken).transfer(_to,_amount);
        require(res);
    }

    function allocStake(address _pair, uint256 _stake) external returns (uint256 _need) {
        address _StakePool = getStakePool[mainToken][_pair];
        require(_StakePool != address(0)," StakePool is null ... ");
        require(msg.sender == _StakePool," StakePool is not manager ... ");
        if (_stake <= 50000000 * decimal) {
            _need = 50000 * decimal;
        } else if (_stake <= 100000000 * decimal) {
            _need = 75000 * decimal;
        } else if (_stake <= 200000000 * decimal) {
            _need = 100000 * decimal;
        } else {
            _need = 125000 * decimal;
        }

        uint256 _balance = YiToken(mainToken).balanceOf(address(this));
        require(_balance >= _need);
        bool res = YiToken(mainToken).transfer(_StakePool,_need);
        require(res);
    }
}