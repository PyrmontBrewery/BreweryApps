//
//  ContentView.swift
//  BeerColour2
//
//  Created by Kev on 23/5/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var showingCamera = false
    @State private var capturedImage: UIImage?
    @State private var analysisResult: BeerAnalysisResult?
    @State private var showingHelp = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Logo and header
                    Text("Beer Color Analyzer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Text("EBC Color Detection")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Image preview or placeholder
                    ZStack {
                        if let image = capturedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 300)
                                .cornerRadius(10)
                                .overlay(
                                    Image(systemName: "camera.circle")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100)
                                        .foregroundColor(.gray)
                                )
                        }
                    }
                    
                    // Analysis results
                    if let result = analysisResult {
                        VStack(spacing: 15) {
                            Text("Results")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                VStack(alignment: .leading) {
                                    Text("EBC Value:")
                                        .fontWeight(.medium)
                                    Text("Beer Color:")
                                        .fontWeight(.medium)
                                    Text("Accuracy:")
                                        .fontWeight(.medium)
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(result.formattedEBC)
                                        .fontWeight(.bold)
                                    Text(result.colorName)
                                        .fontWeight(.bold)
                                    Text(result.accuracyDescription)
                                        .fontWeight(.bold)
                                        .foregroundColor(result.accuracy > 0.6 ? .green : .orange)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(radius: 3)
                            )
                            
                            // Color swatch
                            Rectangle()
                                .fill(Color(result.uiColor))
                                .frame(width: 100, height: 50)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .shadow(radius: 2)
                        }
                    }
                    
                    Spacer()
                    
                    // Capture button
                    Button(action: {
                        self.showingCamera = true
                    }) {
                        HStack {
                            Image(systemName: "camera")
                                .font(.title)
                            Text("Capture Beer Sample")
                                .fontWeight(.medium)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Tips button
                    Button(action: {
                        self.showingHelp = true
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Capture Tips")
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.bottom)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingCamera, onDismiss: analyzeImage) {
                CameraView(image: $capturedImage)
            }
            .alert(isPresented: $showingHelp) {
                Alert(
                    title: Text("Tips for Accurate Results"),
                    message: Text("• Use natural lighting\n• Place beer in clear glass\n• Position camera perpendicular to glass\n• Center beer in yellow target box\n• Avoid shadows and glare\n• Take multiple samples for best results"),
                    dismissButton: .default(Text("Got it!"))
                )
            }
        }
    }
    
    private func analyzeImage() {
        if let image = capturedImage {
            self.analysisResult = BeerColorAnalyzer.analyzeImage(image)
        }
    }
}

#Preview {
    ContentView()
}
