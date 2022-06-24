pragma solidity ^0.5.16;

import "../Owned.sol";
import "./Unimplemented.sol";
import "../interfaces/ISynth.sol";

interface IMockIssuer {
    function synths(bytes32 currencyKey) external view returns (ISynth);
}

contract MockIssuer is Owned, Unimplemented, IMockIssuer {
    mapping(bytes32 => ISynth) public synths;

    constructor(address _owner) public Owned(_owner) {}

    function _addSynth(bytes32 currencyKey, ISynth synth) internal {
        require(synths[currencyKey] == ISynth(0), "Synth exists");
        synths[currencyKey] = synth;
        emit SynthAdded(currencyKey, address(synth));
    }

    function addSynths(bytes32[] calldata currencyKeysToAdd, ISynth[] calldata synthsToAdd) external onlyOwner {
        uint numSynths = currencyKeysToAdd.length;
        require(synthsToAdd.length == numSynths, "Input array lengths must match");
        for (uint i = 0; i < numSynths; i++) {
            _addSynth(currencyKeysToAdd[i], synthsToAdd[i]);
        }
    }

    event SynthAdded(bytes32 currencyKey, address synth);
}

pragma solidity ^0.5.16;

// https://docs.synthetix.io/contracts/source/contracts/owned
contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

pragma solidity ^0.5.16;

contract Unimplemented {
    function() external {
        revert("Unimplemented");
    }
}

pragma solidity >=0.4.24;

// https://docs.synthetix.io/contracts/source/interfaces/isynth
interface ISynth {
    // Views
    function currencyKey() external view returns (bytes32);

    function transferableSynths(address account) external view returns (uint);

    // Mutative functions
    function transferAndSettle(address to, uint value) external returns (bool);

    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);

    // Restricted: used internally to Synthetix
    function burn(address account, uint amount) external;

    function issue(address account, uint amount) external;
}