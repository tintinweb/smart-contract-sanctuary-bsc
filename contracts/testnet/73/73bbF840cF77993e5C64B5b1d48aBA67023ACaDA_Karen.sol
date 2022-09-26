// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.7;

import "./Fallback.sol";
import "./libSip.sol";
import "./IKaren.sol";

contract Karen is 
Fallback, IKaren
{
    using SafeMath for uint;
    using libSip for string;

    address[] private m_allUsers;
    mapping(address => User) private m_users;
    mapping(string => address) private m_sipcodes;
    mapping(address => uint256) private m_sipcodeIt; // Iterator for "random" sipcodes

    constructor() 
    Fallback("0.1")
    {
        m_users[address(this)].accessLevel = AccessLevel.Contract;
        m_users[msg.sender].accessLevel = AccessLevel.Developer;
    }

    function getMyUser() 
    external view override
    returns(User memory)
    {
        return m_users[msg.sender];
    }

    function getUser(address userAddress) 
    external view override
    returns(User memory)
    {
        return m_users[userAddress];
    }

    function getUserForSipcode(string calldata sipcode) 
    external view override
    returns(User memory)
    {
        return m_users[m_sipcodes[sipcode]];
    }

    function snapshot() 
    external view override
    returns(ExportedUser[] memory)
    {
        address[] memory allUsers = m_allUsers;
        ExportedUser[] memory outArr = new ExportedUser[](allUsers.length);
        for(uint256 i; i < allUsers.length; i++) {
            address userAddress = allUsers[i];
            if(userAddress == libSip.ZERO) {
                continue;
            }
            outArr[i] = ExportedUser(userAddress, m_users[userAddress]);
        }
        return outArr;
    }

    function sipcodeExists(string memory sipcode) 
    external view override 
    returns(bool) 
    {
        return m_sipcodes[sipcode.toLower()] != libSip.ZERO;
    }

    function validSipcodeUsage(address caller, string memory sipcode) 
    external view override
    returns(bool) 
    {
        address userAddress = m_sipcodes[sipcode.toLower()];
        return userAddress != libSip.ZERO && caller != userAddress && !m_users[userAddress].banned;
    }

    function getSipcodeAddress(string memory sipcode) 
    external view override
    returns(address)
    {
        return m_sipcodes[sipcode.toLower()];
    }

    function validFreeSipcode(string calldata sipcode) external view override returns(bool)
    {
        string memory sipcodelc = sipcode.toLower();
        return m_sipcodes[sipcodelc] == libSip.ZERO && sipcodelc.validString();
    }

    // Free (semi random) sipcodes for everyone!
    function getRandomSipcode(bool removeOld) external override
    returns(string memory)
    {
        require(!m_users[msg.sender].banned);
        string memory randomSip;
        uint256 sipIt = m_sipcodeIt[msg.sender];
        // we're cutting codes down and we need to verify that we dont get duplicates
        bool kThatsGoodYouCanStopLol;
        do
        {
            uint64 randomBytes = uint64(uint(keccak256(abi.encodePacked(block.timestamp + ++sipIt, msg.sender))));
            randomSip = libSip.uint2hexstr(randomBytes).toLower();
            kThatsGoodYouCanStopLol = m_sipcodes[randomSip] == libSip.ZERO && randomSip.validString();
        }
        while(!kThatsGoodYouCanStopLol);

        require(_createSipcode(msg.sender, randomSip, removeOld), "Random sipcode creation failed?..");
        m_sipcodeIt[msg.sender] = sipIt;
        emit RandomSipcodeCreated(msg.sender, randomSip);
        return randomSip;
    }

    function createSipcodeFor(address userAddress, string memory desiredSipcode, bool removeOld) 
    external override returns(bool)
    {
        // No reverts since 
        User memory user = m_users[msg.sender];
        if(user.accessLevel < AccessLevel.Developer) {
            libSip.onlyContracts(user.accessLevel, msg.sender);
        }
        
        bool succ = _createSipcode(userAddress, desiredSipcode, removeOld);
        if(succ) {
            emit CustomSipcodeCreated(userAddress, desiredSipcode);
        }
        return succ;
    }

    // Rarely if ever used. Ecosystem contracts have their own purchase functions
    function setUserTaxExemptStatus(address userAddress, bool taxExempt) external override
    {
        libSip.onlyAdministrators(m_users[msg.sender].accessLevel);
        emit UserTaxExemptStatusChanged(userAddress, taxExempt);
        m_users[userAddress].taxExempt = taxExempt;

        emit UserTaxExemptStatusChanged(userAddress, taxExempt);
    }

    function removeSipcodeFromAddress(address userAddress) external override
    {
        _removeSipcodeFrom(m_users[msg.sender].accessLevel, m_users[userAddress], userAddress);
    }
 
    function removeSipcode(string memory sipcode) external override
    {
        require(!sipcode.empty());
        address userAddress = m_sipcodes[sipcode.toLower()];
        _removeSipcodeFrom(m_users[msg.sender].accessLevel, m_users[userAddress], userAddress);
    }

    function removeMySipcode(bool areYouSure) external override 
    {
        string memory sipcode = m_users[msg.sender].sipcode;
        require(areYouSure && msg.sender != libSip.ZERO && !sipcode.empty());
        m_sipcodes[sipcode.toLower()] = libSip.ZERO;
        m_users[msg.sender].sipcode = "";
    }

    function resetUser(address userAddress) external override 
    {
        User memory caller = m_users[msg.sender];
        libSip.onlyAdministrators(caller.accessLevel);
        libSip.pullRank(caller.accessLevel, m_users[userAddress].accessLevel);
        _resetUser(userAddress);
    }

    function increaseUserStats(address userAddress, uint256 value) external override
    returns(bool)
    {
        if(value <= 0.0) {
            // we dont want to revert if the user didnt get anything, so no asserts
            return false;
        }

        libSip.onlyContracts(m_users[msg.sender].accessLevel, msg.sender);

        m_users[userAddress].amountEarned = m_users[userAddress].amountEarned.add(value);
        m_users[userAddress].numberOfSales++;
        return true;
    }

    function resetMe(bool areYouSure) external override 
    {
        require(areYouSure);
        _removeSipcode(msg.sender);
        AccessLevel accessLevel = m_users[msg.sender].accessLevel;
        m_users[msg.sender] = User(false, false, false, accessLevel, 0, 0, "");
    }

    function setUserBanStatus(address userAddress, bool isBanned, bool postEvent) external override
    {
        AccessLevel callerRank = m_users[msg.sender].accessLevel;
        libSip.onlyAdministrators(callerRank);
        libSip.pullRank(callerRank, m_users[userAddress].accessLevel);
        if(postEvent){
            emit UserBanStatusChanged(userAddress, isBanned);
        }
        _resetUser(userAddress);
        m_users[userAddress].banned = isBanned;
    }

    function setUsersBanStatus(address[] calldata userAddresses, bool isBanned) external override
    {
        AccessLevel callerRank = m_users[msg.sender].accessLevel;
        libSip.onlyAdministrators(callerRank);
        for(uint256 i = 0; i < userAddresses.length; i++) 
        {
            address userAddress = userAddresses[i];
            User memory user = m_users[userAddress];
            if(userAddress == msg.sender || callerRank <= user.accessLevel || userAddress == libSip.ZERO)
            {
                continue;
            }
            _resetUser(userAddress);
            m_users[userAddress].banned = isBanned;
        }
        emit UsersBanStatusChanged(userAddresses, isBanned);
    }

    function setUserAccessLevel(address userAddress, AccessLevel accessLevel) external override
    {
        AccessLevel callerRank = m_users[msg.sender].accessLevel;
        libSip.onlyDevelopers(callerRank);
        if(accessLevel == AccessLevel.Contract) {
            require(userAddress.code.length > 0, "Error; not a contract");
        }
        m_users[userAddress].accessLevel = accessLevel;
        emit UserAccessLevelChanged(userAddress, accessLevel);
    }

    function _removeSipcode(address userAddress) private
    returns(bool)
    {
        if(userAddress == libSip.ZERO || m_users[userAddress].sipcode.empty()) {
            return false;
        }
        string memory sipcode = m_users[userAddress].sipcode;
        m_sipcodes[sipcode.toLower()] = libSip.ZERO;
        m_users[userAddress].sipcode = "";
        return true;
    }

    function _removeSipcodeFrom(IKaren.AccessLevel callerAccessLevel, User memory user,  address userAddress) private
    {
        if(userAddress != msg.sender) {
            libSip.onlyAdministrators(callerAccessLevel);
            libSip.pullRank(callerAccessLevel, user.accessLevel);
        }
        require(userAddress != libSip.ZERO);
        m_sipcodes[user.sipcode.toLower()] = libSip.ZERO;
        m_users[userAddress].sipcode = "";
    }

    function _resetUser(address userAddress) private 
    {
        _removeSipcode(userAddress);
        m_users[userAddress] = User({
            init: true,
            banned: false,
            taxExempt: false,
            accessLevel: AccessLevel.User, 
            numberOfSales: 0,
            amountEarned: 0,
            sipcode: ""});
    }

    function _createSipcode(address userAddress, string memory desiredSipcode, bool removeOld) private returns(bool)
    {
        string memory desiredSipcodeLower = desiredSipcode.toLower();
        address currentOwner = m_sipcodes[desiredSipcodeLower];
        if(currentOwner != libSip.ZERO || !desiredSipcodeLower.validString()) 
        {
            return false;
        }

        User memory user = m_users[userAddress];
        // Something to maintain a permanent list of users
        if(!user.init) {
            user.init = true;
            m_allUsers.push(userAddress);
        }

        // Does the user have a previously set sipcode
        if(!user.sipcode.empty()) 
        {
            // Allow removing it or GTFO
            if(!removeOld) {
                return false;
            }
            _removeSipcode(userAddress);
        }

        m_sipcodes[desiredSipcodeLower] = userAddress;
        user.sipcode = desiredSipcode;
        m_users[userAddress] = user;
        return true;
    }
}