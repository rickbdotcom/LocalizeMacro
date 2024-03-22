//
//  ContentView.swift
//  LocalizeExample
//
//  Created by Burgess, Rick (CHICO-C) on 3/22/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text(L10n.hello)
            Text(L10n.things(people: 1, geese: 1, "this month", 1))
            Text(L10n.things(people: 1, geese: 2, "this week", 1))
            Text(L10n.things(people: 1, geese: 1, "ago", 2))
            Text(L10n.things(people: 1, geese: 2, "ago", 2))
            Text(L10n.things(people: 2, geese: 1, "ago", 1))
            Text(L10n.things(people: 2, geese: 2, "ago", 1))
            Text(L10n.things(people: 2, geese: 1, "ago", 2))
            Text(L10n.things(people: 2, geese: 2, "ago", 2))
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
