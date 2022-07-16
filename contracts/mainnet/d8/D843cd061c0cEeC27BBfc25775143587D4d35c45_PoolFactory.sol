//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./TransparentUpgradeableProxy.sol";
import "./Address.sol";
import "./Initializable.sol";

contract PoolFactory is Ownable, Initializable {
    using Address for address;

    address public logic;
    address public proxyAdmin;

    address[] public pools;

    address wETH;

    address operator;

    mapping(address => address) public poolOwner;
    mapping(address => address[]) public ownerPools;
    mapping(address => bool) public allowedDepositToken;

    event OpenPool(
        address indexed pool,
        address indexed master,
        address depositToken,
        uint256 masterFee,
        uint256 referralFee,
        uint256 datetime
    );

    function init() public initializer {
        _transferOwnership(msg.sender);
    }

    function setup(
        address _logic,
        address _proxyAdmin,
        address _wETH,
        address _operator
    ) public onlyOwner {
        logic = _logic;
        proxyAdmin = _proxyAdmin;
        wETH = _wETH;
        operator = _operator;
    }

    function exist(address pool) external view returns (bool) {
        return poolOwner[pool] != address(0);
    }

    function getPools(uint256 start, uint256 limit)
        public
        view
        returns (address[] memory)
    {
        require(pools.length > 0, "NO_POOL");
        address[] memory _pools = new address[](limit);

        uint256 end = start + limit;
        if (end > pools.length) {
            end = pools.length;
        }
        uint256 j = 0;
        for (uint256 i = start; i < end; i++) {
            _pools[j] = pools[i];
            j++;
        }

        return _pools;
    }

    function getOwnerPools(address account)
        public
        view
        returns (address[] memory _pools)
    {
        require(ownerPools[account].length > 0, "NO_POOL");
        _pools = new address[](ownerPools[account].length);

        for (uint256 i = 0; i < ownerPools[account].length; i++) {
            _pools[i] = ownerPools[account][i];
        }
    }

    function openPool(
        address depositToken,
        uint256 masterFee,
        uint256 referralFee
    ) public {
        require(
            address(msg.sender).isContract() == false,
            "ONLY_PERSONAL_ADDRESS"
        );
        require(
            allowedDepositToken[depositToken] == true,
            "INVALID_DEPOSIT_TOKEN"
        );
        require(
            masterFee <= 5000 &&
                referralFee <= 5000 &&
                (masterFee + referralFee) <= 5000,
            "INVALID_FEE_SETUP"
        );
        require(ownerPools[msg.sender].length < 100, "POOL_LIMIT");

        TransparentUpgradeableProxy newPool = new TransparentUpgradeableProxy(
            logic,
            proxyAdmin,
            abi.encodeWithSignature(
                "initialize(address,address,address,uint256,uint256,address,address)",
                address(this),
                msg.sender,
                depositToken,
                masterFee,
                referralFee,
                wETH,
                operator
            )
        );
        pools.push(address(newPool));
        poolOwner[address(newPool)] = msg.sender;
        ownerPools[msg.sender].push(address(newPool));

        emit OpenPool(
            address(newPool),
            msg.sender,
            depositToken,
            masterFee,
            referralFee,
            block.timestamp
        );
    }

    function setAllowedDepositToken(address token, bool isAllowed)
        public
        onlyOwner
    {
        allowedDepositToken[token] = isAllowed;
    }

    function setLogic(address _newLogic) public onlyOwner {
        require(_newLogic != address(0), "INVALID_LOGIC");
        logic = _newLogic;
    }
}