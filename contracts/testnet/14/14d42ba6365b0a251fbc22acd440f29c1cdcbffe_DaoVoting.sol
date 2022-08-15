/**
 *Submitted for verification at BscScan.com on 2022-08-15
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-27
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
interface IWineryNFT {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getLevel(uint256 tokenId) external view returns (uint256);
}
contract DaoVoting {
    IWineryNFT public wineryNFT;
    uint256 proposalId;
    address owner;
    uint256 public nonce;
    struct Proposal {
        uint256 proposalId;
        string contentUrl;
        uint256 start;
        uint256 end;
        bool isDeleted;
        uint256 count;
    }
    Proposal[] public proposals;
    struct VoteOption {
        string content;
        uint256 point;
        uint256 count;
    }
    mapping(uint256 => mapping(address => uint256)) public votes; // proposalId => user => optionId
    mapping(uint256 => mapping(address => bool)) public isVoted; // proposalId => user => true/false
    mapping(uint256 => VoteOption[]) public voteOptions; // proposalId => VoteOption
    event Vote(address indexed voter, uint256 proposalId, uint256 optionId);
    event NewProposal(
        uint256 proposalId,
        string contentUrl,
        uint256 start,
        uint256 end
    );
    constructor(IWineryNFT nft) {
        wineryNFT = nft;
        owner = msg.sender;
    }
    function createProposal(
        string memory _contentUrl,
        uint256 _start,
        uint256 _end,
        string[] memory _options
    ) public {
        require(_options.length > 0, "Invalid option length");
        require(_end > block.timestamp, "End must gt Now");
        require(_end > _start, "End must gt Start");
        proposals.push(
            Proposal({
                proposalId: proposalId,
                contentUrl: _contentUrl,
                start: _start,
                end: _end,
                isDeleted: false,
                count: 0
            })
        );
        for (uint256 i = 0; i < _options.length; i++) {
            voteOptions[proposalId].push(
                VoteOption({content: _options[i], point: 0, count: 0})
            );
        }
        emit NewProposal(proposalId, _contentUrl, _start, _end);
        proposalId++;
    }
    function verifyMessage(
        string memory _contentUrl,
        uint256 _start,
        uint256 _endOffset,
        address _sender,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public returns (bool) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 hashedMessage = keccak256(
            abi.encode(_contentUrl, _start, _endOffset, _sender, nonce++)
        );
        bytes32 prefixedHashMessage = keccak256(
            abi.encodePacked(prefix, hashedMessage)
        );
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer == owner;
    }
    function createProposalPermit(
        string memory _contentUrl,
        uint256 _start,
        uint256 _endOffset,
        string[] memory _options,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public {
        require(
            verifyMessage(
                _contentUrl,
                _start,
                _endOffset,
                msg.sender,
                _v,
                _r,
                _s
            ),
            "Not Accepted"
        );
        createProposal(_contentUrl, _start, _endOffset, _options);
    }
    function getOptions(uint256 _proposalId)
        public
        view
        returns (VoteOption[] memory)
    {
        return voteOptions[_proposalId];
    }
    function vote(
        uint256 _proposalId,
        uint256 _optionIndex,
        uint256 _tokenId
    ) public {
        require(_proposalId < proposalId, "Invalid id proposal");
        require(
            _optionIndex < voteOptions[_proposalId].length,
            "Invalid index option"
        );
        require(
            proposals[_proposalId].start < block.timestamp,
            "Proposal not start"
        );
        require(!isVoted[_proposalId][msg.sender], "Voted yet!");
        require(wineryNFT.ownerOf(_tokenId) == msg.sender, "Not owner");
        uint256 level = wineryNFT.getLevel(_tokenId);
        voteOptions[_proposalId][_optionIndex].point += level;
        voteOptions[_proposalId][_optionIndex].count += 1;
        votes[_proposalId][msg.sender] = _optionIndex;
        isVoted[_proposalId][msg.sender] = true;
        proposals[_proposalId].count += 1;
        emit Vote(msg.sender, _proposalId, _optionIndex);
    }
    function deleteProposal(uint256 _proposalId) public {
        require(_proposalId < proposalId, "Invalid index");
        require(proposals[_proposalId].end > block.timestamp, "Proposal end");
        proposals[_proposalId].isDeleted = true;
    }
    function getPropasalInfo(uint256 _proposalId)
        public
        view
        returns (Proposal memory, VoteOption[] memory)
    {
        return (proposals[_proposalId], voteOptions[_proposalId]);
    }
    modifier onlyOwner() {
        require(msg.sender == owner, "Permission");
        _;
    }
}