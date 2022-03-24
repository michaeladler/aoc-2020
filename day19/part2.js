// Source: https://github.com/lagodiuk/earley-parser-js

//   Copyright 2015 Yurii Lahodiuk (yura.lagodiuk@gmail.com)
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

var tinynlp = (function(){
    
    function Grammar(rules) {
        this.lhsToRhsList = {};
        for (var i in rules) {
            var rule = rules[i];
            // "A -> B C | D" -> ["A ", " B C | D"]
            var parts = rule.split('->');
            // "A"
            var lhs = parts[0].trim();
            // "B C | D"
            var rhss = parts[1].trim();
            // "B C | D" -> ["B C", "D"]
            var rhssParts = rhss.split('|');
            if (!this.lhsToRhsList[lhs]) {
                this.lhsToRhsList[lhs] = [];
            }
            for (var j in rhssParts) {
                this.lhsToRhsList[lhs].push(rhssParts[j].trim().split(' '));
            }
            // now this.lhsToRhsList contains list of these rules:
            // {... "A": [["B", "C"], ["D"]] ...}
        }
    }
    Grammar.prototype.terminalSymbols = function(token) {
        return [];
    }
    Grammar.prototype.getRightHandSides = function(leftHandSide) {
            var rhss = this.lhsToRhsList[leftHandSide];
            if (rhss) {
                return rhss;
            }
            return null;
    }
    Grammar.prototype.isEpsilonProduction = function(term) {
        // This is needed for handling of epsilon (empty) productions
        // TODO: get rid of this hardcode name for epsilon productions
        return "_EPSILON_" == term;
    }
    
    //------------------------------------------------------------------------------------
    
    loggingOn = false;
    function logging(allow) {
        loggingOn = allow;
    }

    function Chart(tokens) {
        this.idToState = {};
        this.currentId = 0;
        this.chart = [];
        for (var i = 0; i < tokens.length + 1; i++) {
            this.chart[i] = [];
        }
    }
    Chart.prototype.addToChart = function(newState, position) {
        newState.setId(this.currentId);
        // TODO: use HashSet + LinkedList
        var chartColumn = this.chart[position];
        for (var x in chartColumn) {
            var chartState = chartColumn[x];
            if (newState.equals(chartState)) {
            
                var changed = false; // This is needed for handling of epsilon (empty) productions
                
                changed = chartState.appendRefsToChidStates(newState.getRefsToChidStates());
                return changed;
            }
        }
        chartColumn.push(newState);
        this.idToState[this.currentId] = newState;
        this.currentId++;
        
        var changed = true; // This is needed for handling of epsilon (empty) productions
        return changed;
    }
    Chart.prototype.getStatesInColumn = function(index) {
        return this.chart[index];
    }
    Chart.prototype.countStatesInColumn = function(index) {
        return this.chart[index].length;
    }
    Chart.prototype.getState = function(id) {
        return this.idToState[id];
    }
    Chart.prototype.getFinishedRoot = function( rootRule ) {
        var lastColumn = this.chart[this.chart.length - 1];
        for(var i in lastColumn) {
            var state = lastColumn[i];
            if(state.complete() && state.getLeftHandSide() == rootRule ) {
                // TODO: there might be more than one root rule in the end
                // so, there is needed to return an array with all these roots
                return state;
            }
        }
        return null;
    }
    Chart.prototype.log = function(column) {
        if(loggingOn) {
            console.log('-------------------')
            console.log('Column: ' + column)
            console.log('-------------------')
            for (var j in this.chart[column]) {
                console.log(this.chart[column][j].toString())
            }
        }
    }
    
    //------------------------------------------------------------------------------------
    
    function State(lhs, rhs, dot, left, right) {
        this.lhs = lhs;
        this.rhs = rhs;
        this.dot = dot;
        this.left = left;
        this.right = right;
        this.id = -1;
        this.ref = [];
        for (var i = 0; i < rhs.length; i++) {
            this.ref[i] = {};
        }
    }
    State.prototype.complete = function() {
        return this.dot >= this.rhs.length;
    }
    State.prototype.toString = function() {
        var builder = [];
        builder.push('(id: ' + this.id + ')');
        builder.push(this.lhs);
        builder.push('→');
        for (var i = 0; i < this.rhs.length; i++) {
            if (i == this.dot) {
                builder.push('•');
            }
            builder.push(this.rhs[i]);
        }
        if (this.complete()) {
            builder.push('•');
        }
        builder.push('[' + this.left + ', ' + this.right + ']');
        builder.push(JSON.stringify(this.ref))
        return builder.join(' ');
    }
    State.prototype.expectedNonTerminal = function(grammar) {
        var expected = this.rhs[this.dot];
        var rhss = grammar.getRightHandSides(expected);
        if (rhss !== null) {
            return true;
        }
        return false;
    }
    State.prototype.setId = function(id) {
        this.id = id;
    }
    State.prototype.getId = function() {
        return this.id;
    }
    State.prototype.equals = function(otherState) {
        if (this.lhs === otherState.lhs && this.dot === otherState.dot && this.left === otherState.left && this.right === otherState.right && JSON.stringify(this.rhs) === JSON.stringify(otherState.rhs)) {
            return true;
        }
        return false;
    }
    State.prototype.getRefsToChidStates = function() {
        return this.ref;
    }
    State.prototype.appendRefsToChidStates = function(refs) {
    
        var changed = false; // This is needed for handling of epsilon (empty) productions
        
        for (var i = 0; i < refs.length; i++) {
            if (refs[i]) {
                for (var j in refs[i]) {
                    if(this.ref[i][j] != refs[i][j]) {
                    	changed = true;
                    }
                    this.ref[i][j] = refs[i][j];
                }
            }
        }
        return changed;
    }
    State.prototype.predictor = function(grammar, chart) {
        var nonTerm = this.rhs[this.dot];
        var rhss = grammar.getRightHandSides(nonTerm);
        var changed = false; // This is needed for handling of epsilon (empty) productions
        for (var i in rhss) {
            var rhs = rhss[i];
            
            // This is needed for handling of epsilon (empty) productions
            // Just skipping over epsilon productions in right hand side
            // However, this approach might lead to the smaller amount of parsing tree variants
            var dotPos = 0;
            while(rhs && (dotPos < rhs.length) && (grammar.isEpsilonProduction(rhs[dotPos]))) {
            	dotPos++;
            }
            
            var newState = new State(nonTerm, rhs, dotPos, this.right, this.right);
            changed |= chart.addToChart(newState, this.right);
        }
        return changed;
    }
    State.prototype.scanner = function(grammar, chart, token) {
        var term = this.rhs[this.dot];
        
        var changed = false; // This is needed for handling of epsilon (empty) productions
        
        var tokenTerminals = token ? grammar.terminalSymbols(token) : [];
        if(!tokenTerminals) {
            // in case if grammar.terminalSymbols(token) returned 'undefined' or null
            tokenTerminals = [];
        }
        tokenTerminals.push(token);
        for (var i in tokenTerminals) {
            if (term == tokenTerminals[i]) {
                var newState = new State(term, [token], 1, this.right, this.right + 1);
                changed |= chart.addToChart(newState, this.right + 1);
                break;
            }
        }
        
        return changed;
    }
    State.prototype.completer = function(grammar, chart) {
    
        var changed = false; // This is needed for handling of epsilon (empty) productions
        
        var statesInColumn = chart.getStatesInColumn(this.left);
        for (var i in statesInColumn) {
            var existingState = statesInColumn[i];
            if (existingState.rhs[existingState.dot] == this.lhs) {
            
                // This is needed for handling of epsilon (empty) productions
                // Just skipping over epsilon productions in right hand side
                // However, this approach might lead to the smaller amount of parsing tree variants
                var dotPos = existingState.dot + 1;
                while(existingState.rhs && (dotPos < existingState.rhs.length) && (grammar.isEpsilonProduction(existingState.rhs[dotPos]))) {
                  dotPos++;
                }
                
                var newState = new State(existingState.lhs, existingState.rhs, dotPos, existingState.left, this.right);
                // copy existing refs to new state
                newState.appendRefsToChidStates(existingState.ref);
                // add ref to current state
                var rf = new Array(existingState.rhs.length);
                rf[existingState.dot] = {};
                rf[existingState.dot][this.id] = this;
                newState.appendRefsToChidStates(rf)
                changed |= chart.addToChart(newState, this.right);
            }
        }
        
        return changed;
    }
    
    //------------------------------------------------------------------------------------
    
    // Returning all possible correct parse trees
    // Possible exponential complexity and memory consumption!
    // Take care of your grammar!
    // TODO: instead of returning all possible parse trees - provide iterator + callback
    State.prototype.traverse = function() {
        if (this.ref.length == 1 && Object.keys(this.ref[0]).length == 0) {
            // This is last production in parse tree (leaf)
            var subtrees = [];
            if (this.lhs != this.rhs) {
                // prettify leafs of parse tree
                subtrees.push({
                    root: this.rhs,
                    left: this.left,
                    right: this.right
                });
            }
            return [{
                root: this.lhs,
                left: this.left,
                right: this.right,
                subtrees: subtrees
            }];
        }
        var rhsSubTrees = [];
        for (var i = 0; i < this.ref.length; i++) {
            rhsSubTrees[i] = [];
            for (var j in this.ref[i]) {
                rhsSubTrees[i] = rhsSubTrees[i].concat(this.ref[i][j].traverse());
            }
        }
        var possibleSubTrees = [];
        combinations(rhsSubTrees, 0, [], possibleSubTrees);
        var result = [];
        for (var i in possibleSubTrees) {
            result.push({
                root: this.lhs, 
                left: this.left,
                right: this.right,
                subtrees: possibleSubTrees[i]
            })
        }
        return result;
    }
    
    // Generating array of all possible combinations, e.g.:
    // input: [[1, 2, 3], [4, 5]]
    // output: [[1, 4], [1, 5], [2, 4], [2, 5], [3, 4], [3, 5]]
    //
    // Empty subarrays will be ignored. E.g.:
    // input: [[1, 2, 3], []]
    // output: [[1], [2], [3]]
    function combinations(arrOfArr, i, stack, result) {
        if (i == arrOfArr.length) {
            result.push(stack.slice());
            return;
        }
        if(arrOfArr[i].length == 0) {
            combinations(arrOfArr, i + 1, stack, result);
        } else {
            for (var j in arrOfArr[i]) {
                if(stack.length == 0 || stack[stack.length - 1].right == arrOfArr[i][j].left) {
                    stack.push(arrOfArr[i][j]);
                    combinations(arrOfArr, i + 1, stack, result);
                    stack.pop();
                }
            }
        }
    }
    
    //------------------------------------------------------------------------------------
            
    State.prototype.getLeftHandSide = function() {
        return this.lhs;
    }
            
    //------------------------------------------------------------------------------------
    
    function parse(tokens, grammar, rootRule) {
        var chart = new Chart(tokens);
        var rootRuleRhss = grammar.getRightHandSides(rootRule);
        for (var i in rootRuleRhss) {
            var rhs = rootRuleRhss[i];
            var initialState = new State(rootRule, rhs, 0, 0, 0);
            chart.addToChart(initialState, 0);
        }
        for (var i = 0; i < tokens.length + 1; i++) {
        
            var changed = true; // This is needed for handling of epsilon (empty) productions
            
            while(changed) {
                changed = false;
                j = 0;
                while (j < chart.countStatesInColumn(i)) {
                    var state = chart.getStatesInColumn(i)[j];
                    if (!state.complete()) {
                        if (state.expectedNonTerminal(grammar)) {
                            changed |= state.predictor(grammar, chart);
                        } else {
                            changed |= state.scanner(grammar, chart, tokens[i]);
                        }
                    } else {
                        changed |= state.completer(grammar, chart);
                    }
                    j++;
                }
            }
            chart.log(i)
        }
        return chart;
    }    
    
    var exports = {};
    exports.Grammar = Grammar;
    exports.State = State;
    exports.Chart = Chart;
    exports.parse = parse;
    exports.logging = logging;
    return exports;
})();


///////////////////////////////////////////////////////////////////////////////
// My code
///////////////////////////////////////////////////////////////////////////////

// Define grammar
var grammar = new tinynlp.Grammar([
   // Define grammar production rules
  'RULE72 -> rule57 rule83 | rule83 rule83',
  'RULE41 -> rule57 rule83',
  'RULE101 -> rule83 RULE41 | rule57 RULE72',
  'RULE12 -> rule57 rule57',
  'RULE93 -> RULE12 rule57',
  'RULE40 -> rule57 RULE101 | rule83 RULE93',
  'RULE95 -> rule83 | rule57',
  'RULE105 -> RULE95 RULE95',
  'RULE108 -> rule57 RULE95 | rule83 rule83',
  'RULE136 -> rule57 RULE105 | rule83 RULE108',
  'RULE134 -> RULE95 rule83 | rule83 rule57',
  'RULE121 -> RULE134 rule57 | RULE108 rule83',
  'RULE29 -> RULE136 rule83 | RULE121 rule57',
  'RULE89 -> rule57 RULE29 | rule83 RULE40',
  'RULE124 -> rule57 rule57 | rule83 rule83',
  'RULE45 -> rule83 rule57 | rule83 rule83',
  'RULE55 -> RULE124 rule57 | RULE45 rule83',
  'RULE28 -> RULE72 rule57 | RULE124 rule83',
  'RULE34 -> RULE55 rule83 | RULE28 rule57',
  'RULE18 -> rule83 rule57 | rule57 rule83',
  'RULE138 -> rule57 rule57 | rule83 rule57',
  'RULE39 -> rule83 RULE18 | rule57 RULE138',
  'RULE54 -> rule57 rule57 | rule57 rule83',
  'RULE111 -> RULE54 rule83 | RULE18 rule57',
  'RULE119 -> RULE39 rule57 | RULE111 rule83',
  'RULE22 -> rule83 RULE34 | rule57 RULE119',
  'RULE35 -> rule83 RULE22 | rule57 RULE89',
  'RULE85 -> RULE95 rule57 | rule57 rule83',
  'RULE86 -> rule57 RULE12 | rule83 RULE85',
  'RULE129 -> rule57 RULE138 | rule83 RULE108',
  'RULE94 -> rule83 RULE129 | rule57 RULE86',
  'RULE58 -> RULE108 rule57 | RULE72 rule83',
  'RULE26 -> rule57 RULE12 | rule83 RULE124',
  'RULE49 -> RULE58 rule57 | RULE26 rule83',
  'RULE73 -> RULE49 rule83 | RULE94 rule57',
  'RULE33 -> RULE108 rule83 | RULE45 rule57',
  'RULE91 -> rule83 RULE108 | rule57 RULE72',
  'RULE137 -> RULE33 rule83 | RULE91 rule57',
  'RULE19 -> rule83 rule83',
  'RULE68 -> RULE134 rule57 | RULE19 rule83',
  'RULE106 -> RULE41 rule83 | RULE85 rule57',
  'RULE3 -> RULE68 rule57 | RULE106 rule83',
  'RULE52 -> rule83 RULE3 | rule57 RULE137',
  'RULE53 -> rule57 RULE52 | rule83 RULE73',
  'RULE15 -> RULE35 rule83 | RULE53 rule57',
  'RULE127 -> RULE41 rule57 | RULE12 rule83',
  'RULE80 -> rule83 RULE41 | rule57 RULE85',
  'RULE20 -> rule57 RULE127 | rule83 RULE80',
  'RULE98 -> RULE108 rule57 | RULE41 rule83',
  'RULE14 -> rule57 RULE124 | rule83 RULE138',
  'RULE74 -> RULE98 rule57 | RULE14 rule83',
  'RULE131 -> RULE20 rule83 | RULE74 rule57',
  'RULE51 -> rule83 RULE45 | rule57 RULE54',
  'RULE110 -> RULE85 rule57 | RULE18 rule83',
  'RULE7 -> rule57 RULE110 | rule83 RULE51',
  'RULE47 -> rule83 RULE95 | rule57 rule57',
  'RULE37 -> RULE47 rule57 | RULE72 rule83',
  'RULE112 -> RULE138 rule83 | RULE105 rule57',
  'RULE70 -> rule83 RULE37 | rule57 RULE112',
  'RULE30 -> rule83 RULE7 | rule57 RULE70',
  'RULE87 -> RULE131 rule57 | RULE30 rule83',
  'RULE120 -> rule83 RULE105 | rule57 RULE18',
  'RULE100 -> RULE41 rule83 | RULE138 rule57',
  'RULE118 -> RULE100 rule57 | RULE120 rule83',
  'RULE78 -> RULE41 rule83 | RULE19 rule57',
  'RULE92 -> RULE95 RULE138',
  'RULE77 -> rule83 RULE78 | rule57 RULE92',
  'RULE79 -> rule57 RULE118 | rule83 RULE77',
  'RULE36 -> rule57 RULE134 | rule83 RULE41',
  'RULE21 -> RULE45 rule83 | RULE19 rule57',
  'RULE96 -> RULE36 rule57 | RULE21 rule83',
  'RULE97 -> RULE138 rule57 | RULE12 rule83',
  'RULE135 -> rule83 RULE93 | rule57 RULE97',
  'RULE13 -> rule57 RULE135 | rule83 RULE96',
  'RULE133 -> rule57 RULE79 | rule83 RULE13',
  'RULE66 -> RULE87 rule83 | RULE133 rule57',
  'RULE42 -> RULE15 rule83 | RULE66 rule57',
  'RULE8 -> RULE42 | RULE42 RULE8',
  'RULE104 -> RULE18 rule83 | RULE124 rule57',
  'RULE64 -> RULE18 rule83 | RULE19 rule57',
  'RULE5 -> RULE104 rule83 | RULE64 rule57',
  'RULE61 -> rule57 RULE19 | rule83 RULE47',
  'RULE38 -> RULE58 rule57 | RULE61 rule83',
  'RULE113 -> RULE5 rule83 | RULE38 rule57',
  'RULE16 -> RULE12 rule83 | RULE47 rule57',
  'RULE65 -> rule83 RULE72 | rule57 RULE108',
  'RULE117 -> rule83 RULE16 | rule57 RULE65',
  'RULE107 -> rule83 RULE134 | rule57 RULE72',
  'RULE123 -> RULE105 rule83 | RULE134 rule57',
  'RULE76 -> RULE107 rule57 | RULE123 rule83',
  'RULE24 -> rule83 RULE117 | rule57 RULE76',
  'RULE60 -> RULE113 rule83 | RULE24 rule57',
  'RULE116 -> rule83 RULE18 | rule57 RULE72',
  'RULE1 -> rule57 RULE116 | rule83 RULE93',
  'RULE62 -> rule83 RULE134 | rule57 RULE18',
  'RULE109 -> RULE134 rule83 | RULE124 rule57',
  'RULE32 -> RULE62 rule57 | RULE109 rule83',
  'RULE63 -> rule83 RULE1 | rule57 RULE32',
  'RULE125 -> rule83 RULE124 | rule57 RULE72',
  'RULE59 -> RULE55 rule83 | RULE125 rule57',
  'RULE102 -> RULE19 rule57 | RULE72 rule83',
  'RULE103 -> RULE134 rule57 | RULE45 rule83',
  'RULE43 -> rule83 RULE102 | rule57 RULE103',
  'RULE10 -> RULE59 rule83 | RULE43 rule57',
  'RULE44 -> rule83 RULE63 | rule57 RULE10',
  'RULE71 -> RULE60 rule57 | RULE44 rule83',
  'RULE46 -> rule83 RULE47 | rule57 RULE138',
  'RULE84 -> RULE98 rule57 | RULE46 rule83',
  'RULE114 -> rule83 RULE72 | rule57 RULE45',
  'RULE50 -> RULE123 rule83 | RULE114 rule57',
  'RULE130 -> rule57 RULE84 | rule83 RULE50',
  'RULE2 -> rule83 rule57',
  'RULE88 -> RULE41 rule57 | RULE2 rule83',
  'RULE17 -> rule83 RULE88 | rule57 RULE93',
  'RULE82 -> rule83 RULE41 | rule57 RULE138',
  'RULE6 -> rule83 RULE2 | rule57 RULE138',
  'RULE56 -> RULE82 rule83 | RULE6 rule57',
  'RULE48 -> RULE17 rule83 | RULE56 rule57',
  'RULE90 -> rule83 RULE130 | rule57 RULE48',
  'RULE122 -> RULE18 rule83 | RULE41 rule57',
  'RULE9 -> rule57 RULE124 | rule83 RULE105',
  'RULE81 -> RULE122 rule57 | RULE9 rule83',
  'RULE126 -> RULE54 rule83 | RULE45 rule57',
  'RULE27 -> rule83 RULE41',
  'RULE69 -> RULE126 rule83 | RULE27 rule57',
  'RULE23 -> RULE81 rule57 | RULE69 rule83',
  'RULE128 -> RULE45 rule57 | RULE2 rule83',
  'RULE75 -> RULE108 rule83 | RULE105 rule57',
  'RULE132 -> RULE128 rule57 | RULE75 rule83',
  'RULE4 -> RULE41 rule83 | RULE12 rule57',
  'RULE25 -> RULE4 rule83 | RULE62 rule57',
  'RULE115 -> rule83 RULE132 | rule57 RULE25',
  'RULE99 -> RULE115 rule57 | RULE23 rule83',
  'RULE67 -> RULE90 rule83 | RULE99 rule57',
  'RULE31 -> rule83 RULE71 | rule57 RULE67',
  'RULE11 -> RULE42 RULE31 | RULE42 RULE11 RULE31',
  'RULE0 -> RULE8 RULE11',

   // Define terminal symbols
  'rule57 -> b',
  'rule83 -> a',
]);


const fs = require('fs');

const data = fs.readFileSync('input.txt', 'UTF-8');
const lines = data.split(/\r?\n/);

let counter = 0;
lines.forEach((line) => {
  if (line.startsWith("a") || line.startsWith("b")) {
    //console.log("Checking", line)

    // Creating array of tokens
    var tokens = line.split('');

    // Parsing
    var rootRule = 'RULE0';
    var chart = tinynlp.parse(tokens, grammar, rootRule);

    // Get array with all parsed trees
    // In case of ambiguous grammar - there might be more than 1 parsing tree
    var trees =  chart.getFinishedRoot(rootRule);
    if (trees !== null) {
      //console.log("Accepted");
      counter += 1;
    }
  }

});

console.log("Part 2:", counter)

const assert = require('assert');
assert(counter == 243);
