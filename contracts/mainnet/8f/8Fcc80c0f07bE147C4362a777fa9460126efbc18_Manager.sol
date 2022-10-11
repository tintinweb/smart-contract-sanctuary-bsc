// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IManager.sol";

contract Manager is IManager {
    address public dao;
    mapping(address => bool) public operators;

    mapping(address => bool) public platformDex;
    mapping(address => bool) public platformNft;

    mapping(address => uint256) public allowedPayment;
    mapping(address => bool) public allowedNft;

    event SetDao(address _dao, bool _isOperator);
    event UpdateConduitController(address _conduitController);
    event SetOperators(address _address, bool _flag);
    event SetPlatformDex(address _address, bool _flag);

    error NotDao();
    error NotOperator();
    error WrongDaoParam();

    modifier onlyDAO() {
        if (msg.sender != dao) {
            revert NotDao();
        }
        _;
    }

    modifier onlyOperator() {
        if (!operators[msg.sender]) {
            revert NotOperator();
        }

        _;
    }


    constructor(address _dao)  {
        dao = _dao;
        operators[_dao] = true;
    }

    function setDao(address _dao, bool _isOperator) external onlyDAO {
        if (dao == _dao) {
            revert WrongDaoParam();
        }

        operators[dao] = false;

        dao = _dao;
        operators[_dao] = _isOperator;

        emit SetDao(_dao, _isOperator);
    }

    function setOperators(address[] memory _addrs, bool _flag) external onlyDAO {
        for (uint256 i = 0; i < _addrs.length; i++) {
            operators[_addrs[i]] = _flag;

            emit SetOperators(_addrs[i], _flag);
        }
    }


    function setPlatformDex(address _addr, bool _flag) external onlyOperator {
        platformDex[_addr] = _flag;

        emit SetPlatformDex(_addr, _flag);
    }

    function setPlatformNft(address _addr, bool _flag) external onlyOperator {
        platformNft[_addr] = _flag;
        allowedNft[_addr] = _flag;
    }

    function setNftAllowed(address _addr, bool _flag) external onlyOperator {
        allowedNft[_addr] = _flag;
    }

    function setPaymentsAllowed(address[] calldata _payments, uint256[] calldata _minPrices)
        external
        onlyOperator
    {
        for (uint256 i = 0; i < _payments.length; i++) {
            allowedPayment[_payments[i]] = _minPrices[i];
        }
    }

    function allNftAllowed() external view returns (bool) {
        return allowedNft[address(0)];
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IManager {
    function operators(address addr) external view returns (bool);

    function dao() external view returns (address);

    function platformDex(address addr) external view returns (bool);

    function platformNft(address addr) external view returns (bool);

    function allowedPayment(address addr) external view returns (uint256);

    function allowedNft(address addr) external view returns (bool);

    function allNftAllowed() external view returns (bool);
}