/**
 *Submitted for verification at BscScan.com on 2022-12-06
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;



// Part: IToken

interface IToken {
    function transfer(address to, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address _user) external view returns (uint256);

    function totalSupply() external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function burn(uint256 amount) external;

    function burnFrom(address owner, uint256 amount) external;

    function mint(address to, uint256 amount) external;
}

// File: FundDistributor.sol

contract FundDistributor {
    struct Portion {
        uint256 _portion;
        uint256 index;
        bool set;
        uint256 distributed;
    }

    address public owner;

    IToken public BUSD;

    address public treasury;
    address public pff; // PriceFloor Protection
    address[] public teammates;
    mapping(address => Portion) public portion;
    uint256 public totalPortion;

    event AddressUpdate(string _address, address previous, address update);
    event TeammateUpdate(
        address indexed _teammate,
        uint256 index,
        uint256 portion
    );
    event Distributed(
        uint256 amount,
        uint256 treasury,
        uint256 pricefloor,
        uint256 team
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
    }

    constructor(address _busd) {
        owner = msg.sender;
        BUSD = IToken(_busd);
    }

    function setTreasury(address _newTreasury) external onlyOwner {
        emit AddressUpdate("Treasury", treasury, _newTreasury);
        treasury = _newTreasury;
    }

    function setPriceFloorProtection(address _newPFF) external onlyOwner {
        emit AddressUpdate("Treasury", pff, _newPFF);
        pff = _newPFF;
    }

    function setTeammate(address _teammate, uint256 _portion)
        external
        onlyOwner
    {
        Portion storage member = portion[_teammate];
        if (!member.set) {
            teammates.push(_teammate);
            member.set = true;
            member.index = teammates.length - 1;
        } else totalPortion -= member._portion;
        member._portion = _portion;
        totalPortion += _portion;
        emit TeammateUpdate(_teammate, member.index, member._portion);
    }

    function totalTeammates() external view returns (uint256) {
        return teammates.length;
    }

    function distributeFunds(
        uint256 amount,
        uint256 _tr,
        uint256 _pff,
        uint256 _tm
    ) public {
        uint256 totalDistributed = _tr + _pff + _tm;
        uint256 treasuryAmount = (_tr * amount) / totalDistributed;
        uint256 pffAmount = (_pff * amount) / totalDistributed;
        uint256 teamAmount = amount - treasuryAmount - pffAmount;
        uint256 tinyPortion = 0;
        // Transfer to treasury
        if (treasuryAmount > 0)
            BUSD.transferFrom(msg.sender, treasury, treasuryAmount);
        // Transfer to PriceFloorProtection
        if (pffAmount > 0) BUSD.transferFrom(msg.sender, pff, pffAmount);
        // Teammate Transfer Loop
        if (teamAmount > 0)
            for (uint256 i = 0; i < teammates.length; i++) {
                Portion storage member = portion[teammates[i]];
                if (member._portion == 0) continue;
                tinyPortion = (teamAmount * member._portion) / totalPortion;
                member.distributed += tinyPortion;
                BUSD.transferFrom(msg.sender, teammates[i], tinyPortion);
            }
        emit Distributed(amount, treasuryAmount, pffAmount, teamAmount);
    }
}