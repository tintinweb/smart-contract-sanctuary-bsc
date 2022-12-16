// SPDX-License-Identifier: ANCHISA PINYO
pragma solidity ^0.8.12;

interface IBidding {
    function getEventHours(uint256 _programId) external returns (uint256);

    function getAcceptedBidCapacity(uint256 _programId, uint256 _bidId)
        external
        returns (uint256);

    function getAcceptedBidPrice(uint256 _programId, uint256 _bidId)
        external
        returns (uint256);

    function getAcceptedBidOwner(uint256 _programId, uint256 _bidId)
        external
        returns (address);

    function getAcceptedBidDepositAmount(uint256 _programId, uint256 _bidId)
        external
        returns (uint256);

    function hasRole(bytes32 _role, address _account) external returns (bool);

    function updateProgramStatus(uint256 _programId) external;

    function updateBidStatus_Evaluate(
        uint256 _programId,
        uint256 _bidId,
        uint256[] memory _baseline,
        uint256[] memory _energyUsed,
        uint256 _averagePerformance
    ) external;

    function updateBidStatus_Confirm(
        uint256 _programId,
        uint256 _bidId,
        uint256 _incentive,
        uint256 _penalty
    ) external;
}

interface ITHB {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external;

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external returns (uint256);

    function allowance(address owner, address spender)
        external
        returns (uint256);

    function transfer(address recipient, uint256 amount) external;
}

interface IBaseline {
    function createBaseline(uint256[][] memory _meterData)
        external
        returns (uint256[] memory, uint256);
}

contract Evaluation {
    ITHB THB;
    IBidding Bidding;
    IBaseline Baseline;

    bytes32 public MDP_ROLE = keccak256("MDP_ROLE");
    bytes32 public DR_PARTICIPANT_ROLE = keccak256("DR_PARTICIPANT_ROLE");
    address public treasuryAddress;

    constructor(
        address _THB,
        address _bidding,
        address _baseline,
        address _treasury
    ) {
        THB = ITHB(_THB);
        Bidding = IBidding(_bidding);
        Baseline = IBaseline(_baseline);
        treasuryAddress = _treasury;
    }

    function evaluate(
        uint256 _programId,
        uint256 _bidId,
        uint256[][] memory _meterData,
        uint256[] memory _energyUsed
    ) public {
        require(
            Bidding.hasRole(MDP_ROLE, msg.sender),
            "Only MDP ROLE can call this"
        );
        uint256 _eventHours = Bidding.getEventHours(_programId);
        (uint256[] memory _baseline, ) = Baseline.createBaseline(_meterData);
        require(
            _baseline.length == _eventHours,
            "Data list (baseline) == event hours"
        );
        require(
            _energyUsed.length == _eventHours,
            "Data list (energyUsed) == event hours"
        );

        uint256 _offerredCapacity = Bidding.getAcceptedBidCapacity(
            _programId,
            _bidId
        );

        uint256[] memory _performance = new uint256[](_eventHours);
        uint256[] memory _reduction = new uint256[](_eventHours);

        for (uint256 i = 0; i < _eventHours; i++) {
            if (_baseline[i] < _energyUsed[i]) {
                _reduction[i] = 0;
                _performance[i] = 0;
            } else if (_baseline[i] >= _energyUsed[i]) {
                _reduction[i] = (_baseline[i] - _energyUsed[i]);
                uint256 _P = ((_baseline[i] - _energyUsed[i]) * 100) /
                    _offerredCapacity;
                if (_P > 100) {
                    _performance[i] = 100;
                } else {
                    _performance[i] = _P;
                }
            }
        }

        uint256 x = 0;
        for (uint256 j = 0; j < _performance.length; j++) {
            x = x + _performance[j];
        }

        uint256 _Pav = x / (_performance.length);

        Bidding.updateBidStatus_Evaluate(
            _programId,
            _bidId,
            _baseline,
            _energyUsed,
            _Pav
        );
    }

    function confirmEvaluation(
        uint256 _programId,
        uint256 _bidId,
        uint256 _Pav
    ) public {
        address _bidOwner = Bidding.getAcceptedBidOwner(_programId, _bidId);
        require(
            Bidding.hasRole(DR_PARTICIPANT_ROLE, msg.sender),
            "Only DR PARTICIPANT ROLE can call this"
        );
        require(_bidOwner == msg.sender, "Confirmed by owner only");

        uint256 _bidPrice = Bidding.getAcceptedBidPrice(_programId, _bidId);
        uint256 _offerredCapacity = Bidding.getAcceptedBidCapacity(
            _programId,
            _bidId
        );
        uint256 _eventHours = Bidding.getEventHours(_programId);

        (uint256 _incentive, uint256 _penalty) = _compensation(
            _Pav,
            _offerredCapacity * _eventHours,
            _bidPrice
        );

        uint256 _depositAmount = Bidding.getAcceptedBidDepositAmount(
            _programId,
            _bidId
        );

        _incentive > 0
            ? THB.transferFrom(
                treasuryAddress,
                _bidOwner,
                _incentive + _depositAmount
            )
            : THB.transferFrom(
                treasuryAddress,
                _bidOwner,
                _depositAmount - _penalty
            );

        Bidding.updateBidStatus_Confirm(
            _programId,
            _bidId,
            _incentive,
            _penalty
        );
    }

    function _compensation(
        uint256 _Pav,
        uint256 _offerredReduction,
        uint256 _bidPrice
    ) internal pure returns (uint256 _incentive, uint256 _penalty) {
        if (_Pav >= 75) {
            _incentive = ((_Pav * _offerredReduction * _bidPrice * 1 ether) /
                100000); //100000 = 100percent*1000kW=MW
            _penalty = 0;
        } else if (_Pav < 75 && _Pav >= 60) {
            _incentive =
                (_Pav * _offerredReduction * _bidPrice * 1 ether) /
                200000;
            _penalty = 0;
        } else if (_Pav < 60) {
            _incentive = 0;
            _penalty =
                ((60 - _Pav) * _offerredReduction * _bidPrice * 1 ether) /
                100000;
        }

        return (_incentive, _penalty);
    }
}