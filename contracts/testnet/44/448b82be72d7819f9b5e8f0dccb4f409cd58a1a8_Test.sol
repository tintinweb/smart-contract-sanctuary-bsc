/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

pragma solidity 0.4.25;

contract Test {
  bytes32 private seedKey;

  constructor()  public {
       
        seedKey = bytes32("BinamarsNFTspawner");
    }

     function random(string memory _key, uint256 _length)
        public
        view
        returns (uint256)
    {
      bytes32 _seed = keccak256(abi.encodePacked(_key));
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        blockhash(block.timestamp - block.number),
                        _seed,
                        seedKey,
                        _length,
                        keccak256(abi.encodePacked(msg.sender))
                    )
                )
            ) % (10**_length);
    }

}