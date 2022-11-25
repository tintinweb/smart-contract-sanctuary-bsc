pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "./BridgeInterface.sol";
import "./SignatureChecker.sol";
import "./WrappedTON.sol";


contract Bridge is SignatureChecker, BridgeInterface, WrappedTON {
    address[] public oraclesSet;
    mapping(address => bool) public isOracle;
    mapping(bytes32 => bool) public finishedVotings;

    constructor (string memory name_, string memory symbol_, address[] memory initialSet) ERC20(name_, symbol_) {
        updateOracleSet(0, initialSet);
    }
    
    function generalVote(bytes32 digest, Signature[] memory signatures) internal {
      require(signatures.length >= 2 * oraclesSet.length / 3, "Not enough signatures");
      require(!finishedVotings[digest], "Vote is already finished");
      uint signum = signatures.length;
      uint last_signer = 0;
      for(uint i=0; i<signum; i++) {
        address signer = signatures[i].signer;
        require(isOracle[signer], "Unauthorized signer");
        uint next_signer = uint(signer);
        require(next_signer > last_signer, "Signatures are not sorted");
        last_signer = next_signer;
        checkSignature(digest, signatures[i]);
      }
      finishedVotings[digest] = true;
    }

    function voteForMinting(SwapData memory data, Signature[] memory signatures) override public {
      bytes32 _id = getSwapDataId(data);
      generalVote(_id, signatures);
      executeMinting(data);
    }

    function voteForNewOracleSet(int oracleSetHash, address[] memory newOracles, Signature[] memory signatures) override  public {
      bytes32 _id = getNewSetId(oracleSetHash, newOracles);
      require(newOracles.length > 2, "New set is too short");
      generalVote(_id, signatures);
      updateOracleSet(oracleSetHash, newOracles);
    }

    function voteForSwitchBurn(bool newBurnStatus, int nonce, Signature[] memory signatures) override public {
      bytes32 _id = getNewBurnStatusId(newBurnStatus, nonce);
      generalVote(_id, signatures);
      allowBurn = newBurnStatus;
    }

    function executeMinting(SwapData memory data) internal {
      mint(data);
    }

    function updateOracleSet(int oracleSetHash, address[] memory newSet) internal {
      uint oldSetLen = oraclesSet.length;
      for(uint i = 0; i < oldSetLen; i++) {
        isOracle[oraclesSet[i]] = false;
      }
      oraclesSet = newSet;
      uint newSetLen = oraclesSet.length;
      for(uint i = 0; i < newSetLen; i++) {
        require(!isOracle[newSet[i]], "Duplicate oracle in Set");
        isOracle[newSet[i]] = true;
      }
      emit NewOracleSet(oracleSetHash, newSet);
    }
    function getFullOracleSet() public view returns (address[] memory) {
        return oraclesSet;
    }
}