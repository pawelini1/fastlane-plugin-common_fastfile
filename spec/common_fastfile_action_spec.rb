describe Fastlane::Actions::CommonFastfileAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The common_fastfile plugin is working!")

      Fastlane::Actions::CommonFastfileAction.run(nil)
    end
  end
end
