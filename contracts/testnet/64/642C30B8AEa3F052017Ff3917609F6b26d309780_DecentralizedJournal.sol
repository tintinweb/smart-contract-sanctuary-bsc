/**
 *Submitted for verification at BscScan.com on 2022-11-24
*/

// SPDX-License-Identifier: GPT-3.0

pragma solidity >= 0.7.0 < 0.9.0;

contract DecentralizedJournal {
    struct note {
        string title;
        string content;
        uint256 date;
        uint256 id;
    }

    mapping(address => note[]) journals;
    
    function addNote(string memory _title, string memory _content) public {
        note memory newNote = note(
            _title, 
            _content, 
            block.timestamp, 
            journals[msg.sender].length + 1
        );
        
        journals[msg.sender].push(newNote);
    }

    function getJournal() public view returns(note[] memory) {
        return journals[msg.sender];
    }

    function getOneNote(uint _noteId) public view returns(note memory) {
        return journals[msg.sender][_noteId - 1];
    }

    function getTotalNotes() public view returns(uint256) {
        return journals[msg.sender].length;
    }

    function changeNoteTitle(uint256 _id, string memory _newTitle) public {
        journals[msg.sender][_id - 1].title = _newTitle;
    }

    function changeNoteContent(uint256 _id, string memory _newContent) public {
        journals[msg.sender][_id - 1].content = _newContent;
    }

    function deleteJournal() public {
        delete journals[msg.sender];
    }
}